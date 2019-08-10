/**
 * I am the BookService and I handle getting basic data about a Gitbook from an export folder.
 */
component accessors='true' {

	property name='job'						inject='interactiveJob';
	property name='progressableDownloader'	inject='ProgressableDownloader';
	property name='progressBar'				inject='ProgressBar';
	property name='configService'			inject='configService';

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
	 * Get raw http codes data from httpcodes.json
	 *
	 */
	struct function getHTTPCodes() {
		return deserializeJSON( fileRead( expandPath( '/commandbox-gitbook/includes/httpcodes.json' ), 'UTF-8' ) );
	}

	/**
	 * Get book Title from space.json file
	 *
	 */
	string function getBookTitle( required string bookDirectory ) {
		if( fileExists( bookDirectory & '/space.json' )){
			var spacesObj = deserializeJSON( fileRead( bookDirectory & '/space.json', 'UTF-8' ) );
			return spacesObj.name;
		}
		return ''
	}

	/**
	 * Lookup http code and return description if available
	 *
	 */
	string function getHTTPCodeDesc( httpCode ) {
		var httpCodes = this.getHTTPCodes();
		if( httpCodes.keyExists( httpCode ) ) return httpCodes[ httpCode ];
		if( httpCodes.keyExists( left( httpCode, 1 ) & '00' ) ) return httpCodes[ left( httpCode, 1 ) & '00' ];
		return '';
	}

	/**
	 * Get raw revision data from revisions.json
	 *
	 * @bookDirectory Absolute path to Gitbook
	 */
	struct function getRevisionData( required string bookDirectory ) {
		if( !isBook( bookDirectory ) ) {
			throw( message = 'This folder is not a Gitbook Export', detail = bookDirectory );
		}

		return deserializeJSON( fileRead( bookDirectory & '/revision.json', 'UTF-8' ) );
	}

	/**
	 * Get array of versions in a book
	 *
	 * @bookDirectory Absolute path to Gitbook
	 */
	array function getVersions( required string bookDirectory ) {
		return getRevisionData( bookDirectory ).versions.reduce( (acc, k, v) => acc.append( v.title ), [] );
	}

	/**
	 * Get asset metadata from the revisions file
	 *
	 * @bookDirectory Absolute path to Gitbook
	 */
	struct function getAssets( required string bookDirectory ) {
		return getRevisionData( bookDirectory ).assets;
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
	 * @bookDirectory Absolute path to Gitbook
	 */
	function resolveAssetsToDisk( required string bookDirectory, required string assetDirectory ) {
		job.start( 'Building Assets' );

		var assetCollection = getAssets( bookDirectory );

		directoryCreate( assetDirectory, true, true )

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
			var sourcePath = bookDirectory & '/assets/' & assetData.name;
			var targetFilePath = assetDirectory & '/' & getAssetUniqueName( assetData );
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
	 */
	function resizeImage( required string targetFilePath ) {
		var assetImage = imageRead( targetFilePath );
		if( assetImage.getWidth() > 700 )
			imageScaleTofit(
				assetImage,
				700,
				'',
				'mediumPerformance'
			);
		imageWrite( assetImage, targetFilePath, .8, true );
	}
	
	/**
	 * Resize image to reasonable size
	 */
	function resolveURLEmbedData( required string embedURL ) {
		job.addLog( 'Resolving embed data for URL: #embedURL#' );
		
		var jURL = createObject( 'java', 'java.net.URL' ).init( embedURL );
			
		var embedData = {
			embdedHost = jURL.getHost(),
			pageTitle = jURL.getHost(),
			embedURL = embedURL
		};

		try {
			var proxyServer=ConfigService.getSetting( 'proxy.server', '' )
			var proxyPort=ConfigService.getSetting( 'proxy.port', '' )
			var proxyUser=ConfigService.getSetting( 'proxy.user', '' )
			var proxyPassword=ConfigService.getSetting( 'proxy.password', '' )
			var proxyParams={};
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
			
			http url=embedURL 
				throwOnError=false 
				result="local.httpResult" 
				timeout=20
				attributeCollection=proxyParams;
			
			embedData.pageTitle = XMLSearch( HTMLParse( local.httpResult.fileContent, false ), "//*[translate(local-name(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='title'][1]" )[1].xmlText;
			job.addLog( 'Found: #embedData.pageTitle#' );
			
		} catch( any e ) {
			RETHROW;
		}
		
		
		return embedData;
			
	}

	/**
	 * Get current Version of a book
	 *
	 * @bookDirectory Absolute path to Gitbook
	 */
	function getCurrentVersion( required string bookDirectory ) {
		return getRevisionData( bookDirectory ).primaryVersionID;
	}

	/**
	 * Get struct representing table contents for a version of the book
	 *
	 * @bookDirectory Absolute path to Gitbook
	 * @version A valid version in the this Gitbook
	 */
	array function getTOC( required string bookDirectory, required string version ) {
		job.start( 'Build Table Of Contents' );
		var revisionData = getRevisionData( bookDirectory );
		var TOCData = [];

		if( version == 'current' ) {
			version = revisionData.primaryVersionID;
		}

		var topPage = revisionData.versions[ version ].page;

		if( revisionData.versions.keyExists( version ) ) {
			TOCData.append( [
				'uID' : topPage.keyExists('uID') ? topPage.uID : '',
				'title' : topPage.title,
				'type' :'page',
				'path' : topPage.path,
				'children' :[]
			] );
			TOCData.append( filterPageTitles( topPage.pages ), true );
		}

		job.complete();

		return TOCData;
	}

	/**
	 * Resursive function for filtering page data
	 */
	private function filterPageTitles( required array pages ) {
		return pages.map( (v) => {
			return [
				'uid' : v.keyExists('uID') ? v.uID : '',
				'title' : v.title,
				'type' : v.kind == 'document' ? 'page' : 'section',
				'path' : v.path,
				'children' : filterPageTitles( v.pages )
			];
		} );
	}

}
