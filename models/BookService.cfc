/**
 * I am the BookService and I handle getting basic data about a Gitbook from an export folder.
 */
component accessors='true' {

	property name='job' inject='interactiveJob';
	property name='progressableDownloader' inject='ProgressableDownloader';
	property name='progressBar' inject='ProgressBar';
	property name='configService' inject='configService';

	/**
	 * Constructor
	 */
	function init() {
		return this;
	}

	/**
	 * Detect if the a directory contains a Gitbook export
	 *
	 * @bookDirectory Absolute path to Gitbook
	 */
	function isBook( required string bookDirectory ) {
		return fileExists( bookDirectory & '/revision.json' );
	}

	/**
	 * Generate unique file name from asset metadata
	 *
	 * @assetData A struct containing the following:
	 * {
	 *  uid : '-LlFoCJJ9QnrdHch3YzG',
	 *  name : '61244.jpg'
	 * }
	 */
	string function getAssetUniqueName( required struct assetData ) {
		return 'asset' & assetData.uid & '-' & assetData.name
	}

	/**
	 * Takes asset metadata and ensures each of the assets are avaialble locally
	 * in a folder of your choice.  Unique assets will be transfered from the assets
	 * folder.  Duplicate names will be downloaded again.
	 *
	 * @book Instance of BookExport object
	 */
	function resolveAssetsToDisk( required book ) {
		job.start( 'Building Assets' );

		var assetCollection = book.getAssets();

		directoryCreate( book.getAssetDirectory(), true, true )

		// Find assets in the JSON that have the same name.  We'll need to re-download these!
		var dupeAssets = assetCollection
			.reduce( (dupeAssets, k, v) => {
				dupeAssets[ v.name ] = dupeAssets[ v.name ] ?: 0;
				dupeAssets[ v.name ]++;
				return dupeAssets;
			}, {} )
			.filter( (k, v) => v > 1 );

		// Loop over each asset and transfer it from the assets folder, or download as neccessary
		assetCollection.each( (assetID, assetData) => {
			job.addLog( assetData.name );
			var sourcePath = book.getSourcePath() & '/assets/' & assetData.name;
			var targetFilePath = book.getAssetDirectory() & '/' & getAssetUniqueName( assetData );
			if( !fileExists( targetFilePath ) ) {
				if( fileExists( sourcePath ) && !dupeAssets.keyExists( assetData.name ) ) {
					fileCopy( sourcePath, targetFilePath );
				} else {
					acquireExternalAsset( assetData.downloadURL, targetFilePath );
				}

				// reduce oversized images
				if( isImageFile( targetFilePath ) ) {
					resizeImage( targetFilePath );
				}
			}
		} );

		job.complete();
	}

	/**
	 * Download external asset to local file
	 *
	 * @downloadURL HTTP URL to fetch asset from
	 * @targetFilePath Local file path to save it as
	 */
	function acquireExternalAsset( required string downloadURL, required string targetFilePath ) {
		progressableDownloader.download(
			downloadURL,
			targetFilePath,
			function(status) {
				progressBar.update( argumentCollection = status );
			}
		);
	}

	/**
	 * Resize image to reasonable size
	 *
	 * @targetFilePath Local file path to process.  Will overwrite itself.
	 */
	function resizeImage( required string targetFilePath ) {
		var assetImage = imageRead( targetFilePath );
		if( assetImage.getWidth() > 700 ) imageScaleTofit(
				assetImage,
				700,
				'',
				'mediumPerformance'
			);
		imageWrite( assetImage, targetFilePath, .8, true );
	}

	/**
	 * Resize image to reasonable size
	 *
	 * @embedURL HTTP URL to get embed data from
	 *
	 * @returns a struct with these keys:
	 * - embdedHost
	 * - pageTitle
	 * - embedURL
	 * - pageDescription
	 * - pageIcon
	 */
	function resolveURLEmbedData( required string embedURL ) {
		job.addLog( 'Resolving embed data for URL: #embedURL#' );

		// This Java class gives us handy access to the host part of the URL without custom parsing
		var jURL = createObject( 'java', 'java.net.URL' ).init( embedURL );

		// Our default return data if the try below goes south
		var embedData = {
			embdedHost : jURL.getHost(),
			pageTitle : jURL.getHost(),
			embedURL : embedURL,
			pageDescription : '',
			pageIcon : ''
		};

		try {
			// Account for any proxy config settings the user may have in CommandBox
			var proxyServer = ConfigService.getSetting( 'proxy.server', '' )
			var proxyPort = ConfigService.getSetting( 'proxy.port', '' )
			var proxyUser = ConfigService.getSetting( 'proxy.user', '' )
			var proxyPassword = ConfigService.getSetting( 'proxy.password', '' )
			var proxyParams = {};
			if( len( proxyServer ) ) {
				proxyParams.proxyServer = proxyServer;

				if( len( proxyPort ) ) {
					proxyParams.proxyPort = proxyPort;
				}
				if( len( proxyUser ) ) {
					proxyParams.proxyUser = proxyUser;
				}
				if( len( proxyPassword ) ) {
					proxyParams.proxyPassword = proxyPassword;
				}
			}

			// Hit the URL of the link
			http url=embedURL
 				throwOnError=true
 				result='local.httpResult'
 				timeout=5
 				resolveurl=true
 				attributeCollection=proxyParams;

			// Assume the server is up, HTML comes back, it is parsable.
			var PageXML = htmlParse( local.httpResult.fileContent, false );

			// Look for title
			var titleSearch = xmlSearch(
				PageXML,
				'//*[translate(local-name(),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")="title"][1]'
			);
			if( titleSearch.len() && titleSearch[ 1 ].keyExists( 'xmlText' ) )
				embedData.pageTitle = titleSearch[ 1 ].xmlText;

			// Look for meta description
			var descriptionSearch = xmlSearch(
				PageXML,
				'//*[local-name()="head"]/*[local-name()="meta"][@name="description"][1]'
			);
			if( descriptionSearch.len() && descriptionSearch[ 1 ].XmlAttributes.keyExists( 'content' ) )
				embedData.pageDescription = descriptionSearch[ 1 ].XmlAttributes.content;

			// Look for favicon
			var faviconSearch = xmlSearch( PageXML, '//*[local-name()="head"]/*[local-name()="link"][@rel="icon"][1]' );
			if( faviconSearch.len() && faviconSearch[ 1 ].XmlAttributes.keyExists( 'href' ) )
				embedData.pageIcon = faviconSearch[ 1 ].XmlAttributes.href;

			job.addLog( 'Found: #embedData.pageTitle#' );
		} catch( any e ) {
			// There's a lot of things that could go wrong here, but we're just going to ignore them.
			job.addErrorLog( 'Error getting link preview: #e.message#' );
		}


		return embedData;
	}

}
