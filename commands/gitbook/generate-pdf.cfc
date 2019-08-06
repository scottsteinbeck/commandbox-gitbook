/**
 * run the component to unpack and read a gitbook export
 */
component {

	property name="HTMLRenderer" inject="HTMLRenderer@commandbox-gitbook";
	property name="bookService" inject="BookService@commandbox-gitbook";

	/**
	 * @bookDirectory Directory where the JSON export is for a Gitbook
	 * @version Version of the book to act on.
	 * @version.optionsUDF versionsComplete
	 */
	function run(
		string bookDirectory = resolvePath( '' ),
		string version = configService.getSetting( 'version', 'current' )
	) {
		// For testing, remove later
		pagePoolClear()
		HTMLRenderer = getInstance( 'HTMLRenderer@commandbox-gitbook' );
		bookService = getInstance( 'BookService@commandbox-gitbook' );
		// For testing, remove later

		if( !bookService.isBook( bookDirectory ) ) {
			error( 'A revision.json file is not present in this folder.  Please check your path.' );
		}

		var pageHTML = HTMLRenderer.renderBook( bookDirectory, version );
		cfDocument(format="PDF", filename=resolvePath( "test.pdf" ),  pageType="letter" overwrite=true) {
			writeOutput(this.bodyWrapper( pageHTML ));
		}
		;
		fileWrite( resolvePath( 'test.html' ), this.bodyWrapper( pageHTML ) );
	}


	/**
	 * Wrap the page content in a HTML tag and add in styles
	 * @pageContent
	 */
	function bodyWrapper( required string pageContent ) {
		return HTMLRenderer.renderPartial( 'body-wrapper', { 'data': {} }, pageContent );
	}


	function versionsComplete() {
		try {
			return bookService.getVersions( resolvePath( '' ) );
		} catch( any e ) {
		}
	}

}
