/**
 * Output versions in a Gitbook export.
 */
component {

	property name='BookService' inject='BookService@commandbox-gitbook';

	/**
	 * @sourcePath Directory where the JSON export is for a Gitbook
	 */
	function run( string sourcePath ) {
		
		arguments.sourcePath = resolvePath( arguments.sourcePath ?: '' );
		if( fileExists( sourcepath ) && sourcepath.right( 4 ) == '.zip' ) {
			sourcePath = 'zip://' & sourcePath & '!';
		}
		
		if( !bookService.isBook( sourcePath ) ) {
			error( 'A revision.json file is not present in this path.  Please check your path.' );
		}

		var book = getInstance( 'BookExport@commandbox-gitbook' )
				.setSourcePath( sourcePath )
				.load();
				
		print
			.line()
			.boldCyanLine( book.getTitle() )
			.line();
		
		book
			.getVersions()
			.each( (v) => print.line( ' - #v.title# #v.title != v.id ? "(#v.id#)" : ""#' ) );

	}

}
