/**
 * I a a transient that represents a book's data and the settings to export it
 */
component accessors='true' {

	// DI
	property name='job' inject='interactiveJob';

	property name='sourcePath';
	property name='ExportVersion';
	property name='versions';
	property name='targetPathPartial';
	property name='title';
	property name='logo';
	property name='renderOpts';
	property name='PDFOpts';
	property name='pages';
	property name='bodyWrapperTop';
	property name='bodyWrapperBottom';
	property name='JSONCache';
	property name='assets';
	property name='createPDF';
	property name='createHTML';


	function init() {
		setRenderOpts( {} );
		setPDFOpts( {} );
		setPages( [] );
		setJSONCache( {} );
		setTargetPathPartial( '' );
		setExportVersion( '' )

		return this;
	}

	/**
	 * Load in basic data about book and resolve version
	 */
	function load() {
		// Get book title and logo
		var spacesObj = retrieveJSON( 'space.json' );
		setTitle( spacesObj.name );
		setLogo( spacesObj.logoURL ?: '' );

		// Validate and set export version
		var revisionObj = retrieveJSON( 'revision.json' );
		// If "current", just grab the primary version
		if( getExportVersion() == 'current' ) {
			setExportVersion( getCurrentVersion() );
			// otherwise, if we have a version, search for it
		} else if( getExportVersion().len() ) {
			// && !revisionObj.versions.keyExists( getExportVersion() )
			var versionSearch = revisionObj.versions.filter( ( k, v ) => v.title == getExportVersion() );
			if( versionSearch.len() ) {
				setExportVersion( versionSearch.keyArray().first() );
				// If we didn't find the version title, allow a direct ref name too.
			} else if( !revisionObj.versions.keyExists( getExportVersion() ) ) {
				throw(
					message = 'Versiomn [#getExportVersion()#] does not exist in this book.',
					detail = 'Valid verions are: [#revisionObj.versions.reduce( ( acc, k, v ) => acc.listAppend( v.title ), '' )#]',
					type = 'commandException'
				);
			}
		}

		defaultRenderOpts();

		// Default file name partial if we don't have one.
		if( getTargetPathPartial().endsWith( '\' ) || getTargetPathPartial().endsWith( '/' ) ) {
			setTargetPathPartial( getTargetPathPartial() & slugify( getTitle() ) );
		}

		directoryCreate( getDirectoryFromPath( getPDFExportFilePath() ), true, true );

		return this;
	}


	/**
	 * Get array of structs representing the version titles and IDs in the book
	 *
	 */
	array function getVersions() {
		return retrieveJSON( 'revision.json' ).versions.reduce( ( acc, k, v ) => acc.append( { title : v.title, id : k } ), [] );
	}

	/**
	 * Get asset metadata from the revisions file
	 *
	 */
	struct function getAssets() {
		return retrieveJSON( 'revision.json' ).assets;
	}

	/**
	 * Read JSON for a given page
	 */
	function getPageJSON( pageName ) {
		return retrieveJSON( 'versions/#getExportVersion()#/#pageName#.json' );
	}

	/**
	 * Fetched a cached JSON file by relative path to the sourcePath.
	 *
	 * @absolute Set to true, if passing an external path that's not inside the book sourcePath
	 */
	function retrieveJSON( required string filePath, boolean absolute = false ) {
		if( !absolute ) {
			filePath = sourcePath & '/' & filePath;
		}

		var JSONCache = getJSONCache();
		var hashKey = hash( filePath );
		if( JSONCache.keyExists( hashKey ) ) {
			return JSONCache[ hashKey ];
		}

		var fileContents = fileRead( filePath, 'UTF-8' );
		JSONCache[ hashKey ] = deserializeJSON( fileContents );

		// JSON docs can be null
		if( isNull( JSONCache[ hashKey ] ) ) {
			return;
		} else {
			return JSONCache[ hashKey ];
		}
	}


	/**
	 * Get current Version of a book
	 */
	function getCurrentVersion() {
		return retrieveJSON( 'revision.json' ).primaryVersionID;
	}


	/**
	 * Get struct representing table contents for a version of the book
	 */
	array function getTOC() {
		var revisionData = retrieveJSON( 'revision.json' );
		var TOCData = [];

		// Resursive function for filtering page data
		var filterPageTitles = function( required array pages ) {
			return pages.map( ( v ) => {
				return [
					'uid' : v.keyExists( 'uID' ) ? v.uID : '',
					'title' : v.title,
					'type' : v.kind == 'document' ? 'page' : 'section',
					'path' : v.path,
					'children' : filterPageTitles( v.pages )
				];
			} );
		}
		;

		var topPage = revisionData.versions[ getExportVersion() ].page;

		if( revisionData.versions.keyExists( getExportVersion() ) ) {
			TOCData.append( [
				'uID' : topPage.keyExists( 'uID' ) ? topPage.uID : '',
				'title' : topPage.title,
				'type' :'page',
				'path' : topPage.path,
				'children' :[]
			] );
			TOCData.append( filterPageTitles( topPage.pages ), true );
		}

		return TOCData;
	}

	/**
	 * File name to save PDF export as
	 */
	function getPDFExportFilePath() {
		return getTargetPathPartial() & '.pdf';
	}

	/**
	 * File name to save HTML export as
	 */
	function getHTMLExportFilePath() {
		return getTargetPathPartial() & '.html';
	}

	/**
	 * File name to save mobi export as
	 */
	function getMobiExportFilePath() {
		return getTargetPathPartial() & '.mobi';
	}

	/**
	 * File name to save epub export as
	 */
	function getEpubExportFilePath() {
		return getTargetPathPartial() & '.epub';
	}

	/**
	 * A little UDF to ensure default values are present on the renderOpts struct
	 */
	function defaultRenderOpts() {
		var renderOpts = getRenderOpts();
		renderOpts.coverPageImageFile = renderOpts.coverPageImageFile ?: '';
		renderOpts.codeHighlighlightTheme = renderOpts.codeHighlighlightTheme ?: 'default';
		renderOpts.showTOC = renderOpts.showTOC ?: true;
		renderOpts.showPageNumbers = renderOpts.showPageNumbers ?: true;
	}

	/**
	 * Asset directory to use relative to the book source path
	 */
	function getAssetDirectory() {
		return getSourcePath() & '/resolvedAssets';
	}

	/**
	 * Create a URL safe slug from a string
	 */
	function slugify( required string str, numeric maxLength = 0, string allow = '' ) {
		// Cleanup and slugify the string
		var slug = trim( arguments.str );
		slug = replaceList( slug, '#chr( 228 )#,#chr( 252 )#,#chr( 246 )#,#chr( 223 )#', 'ae,ue,oe,ss' );
		slug = reReplace(
			slug,
			'[^A-Za-z0-9-\s#arguments.allow#]',
			'',
			'all'
		);
		slug = trim( reReplace( slug, '[\s-]+', ' ', 'all' ) );
		slug = reReplace( slug, '\s', '-', 'all' );

		// is there a max length restriction
		if( arguments.maxlength ) {
			slug = left( slug, arguments.maxlength );
		}

		return slug;
	}

	/**
	 * Lookup http code and return description if available
	 *
	 * @httpCode HTTP code such as 404 or 200
	 */
	string function getHTTPCodeDesc( httpCode ) {
		var httpCodes = retrieveJSON( expandPath( '/commandbox-gitbook/includes/httpcodes.json' ), true );
		if( httpCodes.keyExists( httpCode ) ) return httpCodes[ httpCode ];
		if( httpCodes.keyExists( left( httpCode, 1 ) & '00' ) ) return httpCodes[ left( httpCode, 1 ) & '00' ];
		return '';
	}

}
