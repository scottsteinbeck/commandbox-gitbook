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
		return assetData.uid & '-' & assetData.name
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

		// Loop over each asset and transfer it from the assets folder, or download as neccessary
		assetCollection.each( ( assetID, assetData ) => {
			
			var sourcePath = book.getSourcePath() & '/assets/' & getAssetUniqueName( assetData );
			var targetFilePath = book.getAssetDirectory() & '/' & getAssetUniqueName( assetData );
			
			if( !fileExists( targetFilePath ) ) {
				if( fileExists( sourcePath ) ) {
					job.addLog( assetData.name & " (found) ");
					fileCopy( sourcePath, targetFilePath );
				} else {
					job.addLog( assetData.name & " (downloaded)");
					acquireExternalAsset( assetData.downloadURL, targetFilePath );
				}

				// reduce oversized images
				if( fileExists( targetFilePath ) && isImageFile( targetFilePath ) ) {
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
		try {
			progressableDownloader.download(
				downloadURL,
				targetFilePath,
				function( status ) {
					progressBar.update( argumentCollection = status );
				}
			);
		} catch( any var e ) {
			job.addErrorLog( e.message );
		}
	}

	/**
	 * Resize image to reasonable size
	 *
	 * @targetFilePath Local file path to process.  Will overwrite itself.
	 */
	function resizeImage( required string targetFilePath ) {
		// CMKY images not supported, so just ignore
		try {
			var assetImage = imageRead( targetFilePath );
			if( assetImage.getWidth() > 700 ) {
				imageScaleTofit(
					assetImage,
					700,
					'',
					'mediumPerformance'
				);
			}
			if( assetImage.getHeight() > 900 ) {
				imageScaleTofit(
					assetImage,
					'',
					900,
					'mediumPerformance'
				);
			}
			imageWrite( assetImage, targetFilePath, .8, true );
		} catch( any e ) {
			job.addWarnLog( 'Could not resize file.  #e.message# #e.detail#' );
		}
	}

	/**
	 * Resize image to reasonable size
	 *
	 * @node Struct of data for this node
	 * @book Instance of BookExport object
	 *
	 * @returns a struct with these keys:
	 * - embdedHost
	 * - pageTitle
	 * - embedURL
	 * - pageDescription
	 * - pageIcon
	 */
	function resolveURLEmbedData( required struct node, book ) {
		var embedURL = node.data.url;
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

		// If this is a direct link to a PDF file, don't bother looking for HTML.  Add any additiona extensions here to check for
		if( lcase( embedURL ).endsWith( '.pdf' ) ) {
			return embedData;
		}

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

			// Just stop here if this is a PDF or something
			if( !local.httpResult.mimetype contains 'html' ) {
				return embedData;
			}

			// Assume the server is up, HTML comes back, it is parsable.
			var PageXML = htmlParse( local.httpResult.fileContent, false );

			// Look for title
			var titleSearch = xmlSearch(
				PageXML,
				'//*[translate(local-name(),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")="title"][1]'
			);
			if( titleSearch.len() && titleSearch[ 1 ].keyExists( 'xmlText' ) ) {
				embedData.pageTitle = titleSearch[ 1 ].xmlText;
			}

			// Look for meta description
			var descriptionSearch = xmlSearch(
				PageXML,
				'//*[local-name()="head"]/*[local-name()="meta"][@name="description"][1]'
			);
			if( descriptionSearch.len() && descriptionSearch[ 1 ].XmlAttributes.keyExists( 'content' ) ) {
				embedData.pageDescription = descriptionSearch[ 1 ].XmlAttributes.content;
			}

			// Look for favicon
			var faviconSearch = xmlSearch( PageXML, '//*[local-name()="head"]/*[local-name()="link"][@rel="icon"][1]' );
			if( faviconSearch.len() && faviconSearch[ 1 ].XmlAttributes.keyExists( 'href' ) ) {
				var iconURL = faviconSearch[ 1 ].XmlAttributes.href;
				// Decide what we'd call this iamge if we were to have already downloaded it
				var localpath = book.getAssetDirectory() & '/embed-icon-#node.key#-#iconURL.listLast( '/' ).listFirst( '?' )#';
				var actualLocalpath = localpath;
				if( localpath.listLast( '.' ) == 'ico' ) {
					actualLocalpath = localpath & '.png';
				}
				// if it doesn't exist already
				if( !fileExists( localPath ) ) {
					// Download it
					acquireExternalAsset( iconURL, localpath );
					// Convert ICOs to PNGs.
					if( fileExists( localpath ) && localpath.listLast( '.' ) == 'ico' ) {
						convertICOtoPNG( localpath, localpath & '.png' )
						localpath = localpath & '.png';
						resizeImage( localpath );
					}
				}

				embedData.pageIcon = actualLocalpath;

				// Look for a favicon at this URL
			} else {
				try {
					var thisURL = createObject( 'java', 'java.net.URL' ).init( embedURL );
					var iconURL = thisURL.getProtocol() & '://' & thisURL.getHost() & (
						thisURL.getPort() > 0 ? ':' & thisURL.getPort() : ''
					) & '/favicon.ico';
					// Decide what we'd call this iamge if we were to have already downloaded it
					var localpath = book.getAssetDirectory() & '/embed-icon-#node.key#-#iconURL.listLast( '/' ).listFirst( '?' )#';
					var actualLocalpath = localpath;
					if( localpath.listLast( '.' ) == 'ico' ) {
						actualLocalpath = localpath & '.png';
					}
					// if it doesn't exist already
					if( !fileExists( localPath ) ) {
						// Download it
						acquireExternalAsset( iconURL, localpath );
						
						if( fileExists( localpath ) ) {
							// Convert ICOs to PNGs.
							convertICOtoPNG( localpath, localpath & '.png' )
							localpath = localpath & '.png';
							resizeImage( localpath );	
						}
					}

					embedData.pageIcon = actualLocalpath;
				} catch( any e ) {
					job.addWarnLog( 'No favicon found for this link' );
				}
			}

			job.addLog( 'Found: #embedData.pageTitle#' );
		} catch( any e ) {
			// There's a lot of things that could go wrong here, but we're just going to ignore them.
			job.addErrorLog( 'Error getting link preview: #e.message#' );
		}


		return embedData;
	}

	/**
	 * Convert an ICO file to a PNG
	 *
	 * @sourceFile Absolute path of ICO to read in
	 * @targetFile Absolute path of PNG to write out
	 */
	function convertICOtoPNG( required string sourceFile, required string targetFile ) {
		var jSourceFile = createObject( 'java', 'java.io.File' ).init( sourceFile );
		var jTargetFile = createObject( 'java', 'java.io.File' ).init( targetFile );

		// Read in ICO file to array of BufferedImage objects
		var images = createObject( 'java', 'net.sf.image4j.codec.ico.ICODecoder' ).read( jSourceFile );
		// Write out the first image in the array to a PNG file
		createObject( 'java', 'javax.imageio.ImageIO' ).write( images.get( 0 ), 'png', jTargetFile );
	}

}
