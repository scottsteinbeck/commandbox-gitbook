/**
 * Output versions in a Gitbook export.
 */
component {

	property name='BookService' inject='BookService@commandbox-gitbook';

	/**
	 * @bookDirectory Directory where the JSON export is for a Gitbook
	 */
	function run( string bookDirectory = resolvePath( '' ) ) {
		if( !bookService.isBook( bookDirectory ) ) {
			error( 'A revision.json file is not present in this folder.  Please check your path.' );
		}

		bookService.getVersions( bookDirectory ).each( (v) => print.line( v ) );
	}

}
