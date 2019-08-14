/**
 * List the table of contents for a specif version of a Gitbook export
 */
component {

	processingdirective pageEncoding='UTF-8';

	property name='configService' inject='configService';
	property name='BookService' inject='BookService@commandbox-gitbook';

	/**
	 * @sourcePath Directory where the JSON export is for a Gitbook
	 * @version Version of the book to act on.
	 * @version.optionsUDF versionsComplete
	 */
	function run(
		string sourcePath,
		string version = 'current'
	) {
		
		arguments.sourcePath = resolvePath( arguments.sourcePath ?: '' );
		if( fileExists( sourcepath ) && sourcepath.right( 4 ) == '.zip' ) {
			sourcePath = 'zip://' & sourcePath & '!';
		}
		
		if( !bookService.isBook( sourcePath ) ) {
			error( 'A revision.json file is not present in this path.  Please check your path.' );
		}

		var book = getInstance( 'BookExport@commandbox-gitbook' )
				.setSourcePath( sourcePath )
				.setExportVersion( version )
				.load();
			
		print
			.line()
			.boldCyanLine( book.getTitle() & ( book.getVersions().len() ? ' (#book.getExportVersion()#)' : '' ) );
			
		var tocData = book.getTOC();	
		tocData.each( ( section ) => {
			
			print
				.line()
				.indentedBoldAquaLine( section.title );
				
			generateTOCNode( section.children, '    ' );
			
		} );
	}

	/**
	* Recursivley print TOC as a tree
	*/
	private function generateTOCNode( array TOCNodes, string prefix='' ) {
		var i = 0;
		var childrenCount = TOCNodes.len();
		
		TOCNodes.each( ( child ) => {
			i++;
			var children = child.children;
			var childDepCount = children.len();
			var isLast = ( i == childrenCount );
			var branch = ( isLast ? '└' : '├' ) & '─' & ( childDepCount ? '┬' : '─' );
			var branchCont = ( isLast ? ' ' : '│' ) & ' ' & ( childDepCount ? '│' : ' ' );
			
			print.line( prefix & branch & ' ' & child.title );
			if( children.len() ) {
				generateTOCNode( children, prefix & ( isLast ? '  ' : '│ ' ) );
			}
		} );
		
	}


	function versionsComplete() {
		try {
			var sourcepath = resolvepath( arguments.passedNamedParameters.sourcepath ?: '' );
			if( fileExists( sourcepath ) && sourcepath.right( 4 ) == '.zip' ) {
				sourcePath = 'zip://' & sourcePath & '!';
			}
			
			if( bookService.isBook( sourcePath ) ) {
				return getInstance( 'BookExport@commandbox-gitbook' )
					.setSourcePath( sourcePath )
					.getVersions()
					.map( (v) => v.title );
			}
			return [];
			
		} catch( any e ) {
			return [];
		}
	}

}
