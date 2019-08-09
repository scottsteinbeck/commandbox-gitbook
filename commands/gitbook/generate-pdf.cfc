/**
 * run the component to unpack and read a gitbook export
 */
component {

	property name='HTMLRenderer' inject='HTMLRenderer@commandbox-gitbook';
	property name='bookService' inject='BookService@commandbox-gitbook';

/*pageheight
pagewidth 
pagetype
orientation 
margintop 
marginbottom
marginleft 
marginright 
backgroundvisible???
bookmark */


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

		// This is sort of a dumb job step, just created it to have a wrapper since the PDF bit isn't in a service yet
		job.start( 'Processing' );

		HTMLRenderer.renderBookPDF( bookDirectory, version );

		
		job.complete();

		print
			.line()
			.greenLine( 'Complete!' )
			.line()
			.yellowLine( 'PDF written to #resolvePath( 'test.pdf' )#' );
	}

	function versionsComplete() {
		try {
			return bookService.getVersions( resolvePath( '' ) );
		} catch( any e ) {
		}
	}

}
