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
		
		return this;
	}

	function load() {
		var spacesObj = retrieveJSON( 'space.json' );
		setTitle( spacesObj.name );		
		setLogo( spacesObj.logoURL ?: '' );
		
		
		if( getExportVersion() == 'current' ) {
			setExportVersion( retrieveJSON( 'revision.json' ).primaryVersionID );
		}

		defaultRenderOpts();
		
		if( getTargetPathPartial().endsWith( '\' ) || getTargetPathPartial().endsWith( '/' ) ) {
			setTargetPathPartial( getTargetPathPartial() & slugify( getTitle() ) );
		}
		
		directoryCreate( getDirectoryFromPath( getPDFExportFilePath() ), true, true );
		
		return this;
	}


	/**
	 * Get array of versions in a book
	 *
	 */
	array function getVersions() {
		return retrieveJSON( 'revision.json' ).versions.reduce( (acc, k, v) => acc.append( v.title ), [] );
	}

	/**
	 * Get asset metadata from the revisions file
	 *
	 */
	struct function getAssets() {
		return retrieveJSON( 'revision.json' ).assets;
	}
	
	function getPageJSON( pageName ) {
		return retrieveJSON( 'versions/#getExportVersion()#/#pageName#.json' );
	}	

	function retrieveJSON( required string filePath ) {
		filePath = sourcePath & '/' & filePath;
		
		var JSONCache = getJSONCache();
		var hashKey = hash( filePath );
		if( JSONCache.keyExists( hashKey ) ) {
			return JSONCache[ hashKey ];
		}
		
		var fileContents = fileRead( filePath, 'UTF-8' );
		JSONCache[ hashKey ] = deserializeJSON( fileContents );
		return JSONCache[ hashKey ];
	}


	/**
	 * Get current Version of a book
	 *
	 */
	function getCurrentVersion() {
		return retrieveJSON( 'revision.json' ).primaryVersionID;
	}


	/**
	 * Get struct representing table contents for a version of the book
	 *
	 */
	array function getTOC() {
		job.start( 'Build Table Of Contents' );
		var revisionData = retrieveJSON( 'revision.json' );
		var TOCData = [];

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

		job.complete();

		return TOCData;
	}

	/**
	 * Resursive function for filtering page data
	 */
	private function filterPageTitles( required array pages ) {
		return pages.map( (v) => {
			return [
				'uid' : v.keyExists( 'uID' ) ? v.uID : '',
				'title' : v.title,
				'type' : v.kind == 'document' ? 'page' : 'section',
				'path' : v.path,
				'children' : filterPageTitles( v.pages )
			];
		} );
	}
	
	function getPDFExportFilePath() {
		return getTargetPathPartial() & '.pdf';
	}
	
	function getHTMLExportFilePath() {
		return getTargetPathPartial() & '.html';
	}
	function getMobiExportFilePath() {
		return getTargetPathPartial() & '.mobi';
	}
	function getEpubExportFilePath() {
		return getTargetPathPartial() & '.epub';
	}
	
	function defaultRenderOpts() {
		var renderOpts = getRenderOpts();
		renderOpts.coverPageImageFile = renderOpts.coverPageImageFile ?: '';
		renderOpts.codeHighlighlightTheme = renderOpts.codeHighlighlightTheme ?: 'default';
		renderOpts.showTOC = renderOpts.showTOC ?: true;
		renderOpts.showPageNumbers = renderOpts.showPageNumbers ?: true;
	}

	function getAssetDirectory() {
		return getSourcePath() & '/resolvedAssets';		
	}

	// Create a URL safe slug from a string
	function slugify( required string str, numeric maxLength=0, string allow='' ) {
		// Cleanup and slugify the string
		var slug 	= trim( arguments.str );
		slug 		= replaceList( slug, '#chr(228)#,#chr(252)#,#chr(246)#,#chr(223)#', 'ae,ue,oe,ss' );
		slug 		= reReplace( slug, "[^A-Za-z0-9-\s#arguments.allow#]", "", "all" );
		slug 		= trim ( reReplace( slug, "[\s-]+", " ", "all" ) );
		slug 		= reReplace( slug, "\s", "-", "all" );

		// is there a max length restriction
		if( arguments.maxlength ){ slug = left( slug, arguments.maxlength ); }

		return slug;
	}


}
