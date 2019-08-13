/**
 * Generate PDF and other formats from a Gitbook export zip
 *
 * Pagetype definitions are
 * - legal: 8.5 inches x 14 inches
 * - letter: 8.5 inches x 11 inches
 * - A4: 8.27 inches x 11.69 inches
 * - A5: 5.81 inches x 8.25 inches
 * - B5: 9.81 inches x 13.88 inches
 * - Custom: Custom height and width
 * 
 */
component {

	property name='HTMLRenderer'	inject='HTMLRenderer@commandbox-gitbook';
	property name='bookService'		inject='BookService@commandbox-gitbook';
	property name="tempDir" 		inject="tempDir@constants";


	/* 
		backgroundvisible  -- Not sure if there is a use case for this one yet
		bookmark  -- Pointless unless Lucee fixes bugs with documentsections, preventing us from using bookmarks
	 */


	/**
	 * @sourcePath Directory or zip file path where the JSON export is for a Gitbook
	 * @targetDir
	 * @targetFile  
	 * @version Version of the book to act on.
	 * @version.optionsUDF versionsComplete
	 * @pageheight Specifies the page height in inches (default) or centimeters. Only applies to pagetype=custom. 
	 * @pagewidth Specifies the page width in inches (default) or centimeters. Only applies to pagetype=custom.
	 * @pagetype Preset page sizes. legal, letter, A4, A5, B5, Custom. 
	 * @pagetype.options legal,letter,A4,A5,B5,custom	 
	 * @orientation Specifies the page orientation. Specify either of the following: portrait (default), landscape
	 * @orientation.options portrait,landscape
	 * @margintop Specifies the top margin in inches (default) or centimeters.
	 * @marginbottom Specifies the bottom margin in inches (default) or centimeters. 
	 * @marginleft Specifies the left margin in inches (default) or centimeters.
	 * @marginright Specifies the right margin in inches (default) or centimeters. 
	 * @unit Specifies the default unit (inches or centimeters) for pageheight, pagewidth, and margin attributes.
	 * @unit.options in,cm 
	 */
	function run(
		string sourcePath,
		string targetDir,
		string targetFile,
		string version = 'current',
		numeric pageheight,
		numeric pagewidth,
		string pagetype,
		string orientation,
		string margintop,
		string marginbottom,
		string marginleft,
		string marginright,
		string unit
	) {
		// For testing, remove later
		pagePoolClear()
		HTMLRenderer = getInstance( 'HTMLRenderer@commandbox-gitbook' );
		bookService = getInstance( 'BookService@commandbox-gitbook' );
		// For testing, remove later

		arguments.sourcePath = resolvePath( arguments.sourcePath ?: '' );
		var actualSourcePath = arguments.sourcePath;
		
		var cleanUpTemp = false;
		try {
	
			// This is sort of a dumb job step, just created it to have a wrapper since the PDF bit isn't in a service yet
			job.start( 'Processing' );
					
			if( fileExists( arguments.sourcePath ) && arguments.sourcePath.right( 4 ) == '.zip' ) {
				cleanUpTemp = true;
				actualSourcePath = tempDir & '/' & 'gitbook#createUUID()#/';
				job.addLog( 'Unzipping book...' );
				zip action="unzip" file="#arguments.sourcePath#" destination="#actualSourcePath#" overwrite="true";
				job.addLog( 'Done.' );
			}
			
	
			if( !bookService.isBook( actualSourcePath ) ) {
				error( 'A revision.json file is not present in this folder.  Please check your path.' );
			}
	
	
			var renderOpts = {};
			var refArguments = arguments;
			'pageheight,pagewidth,pagetype,orientation,margintop,marginbottom,marginleft,marginright,unit'.listEach( ( p ) => {
				if( !isNull( refArguments[ p ] ) ) {
					renderOpts[ p ] = refArguments[ p ];
				}
			} );
			HTMLRenderer.renderBookPDF( actualSourcePath, version, renderOpts );
			
		} finally {
			if( cleanUpTemp && directoryExists( actualSourcePath ) ) {
				directoryDelete( actualSourcePath, true );
			}
		}	

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
