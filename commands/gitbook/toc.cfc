/**
 * List the table of contents for a specif version of a Gitbook export
 */
component {

	property name="configService" inject="configService";
	property name="BookService" inject="BookService@commandbox-gitbook";

	/**
	 * @bookDirectory Directory where the JSON export is for a Gitbook
	 * @version Version of the book to act on.
	 * @version.optionsUDF versionsComplete
	 */
	function run(
		string bookDirectory = resolvePath( '' ),
		string version = configService.getSetting( 'version', 'current' )
	) {
		if( !bookService.isBook( bookDirectory ) ) {
			error( 'A revision.json file is not present in this folder.  Please check your path.' );
		}

		print.line( bookService.getTOC( bookDirectory, version ) );
	}

	function versionsComplete() {
		try {
			return bookServuce.getVersions( resolvePath( '' ) );
		} catch( any e ) {
		}
	}

}
