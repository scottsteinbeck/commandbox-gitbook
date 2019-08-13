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

	property name='ExportService'	inject='ExportService@commandbox-gitbook';
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
	 * @coverPageImageFile An image that will completely replace the default cover page. Use image same dimensions/size as page.
	 * @codeHighlighlightTheme Name of Pygments theme to use for code blocks. http://jwarby.github.io/jekyll-pygments-themes/
	 * @codeHighlighlightTheme.options autumn,borland,bw,colorful,default,emacs,friendly,fruity,manni,monokai,murphy,native,pastie,perldoc,tango,trac,vim,vs
	 * @showTOC Set to false to not render a Table Of Contents for the book
	 * @showPageNumbers Set to false to not render page numbers in header/footer
	 * @showTitleInPage Set to false to not render page title in header/footer
	 * @verbose Leave full console log for content generation for debugging
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
		string unit,
		string coverPageImageFile='',
		string codeHighlighlightTheme='default',
		boolean showTOC=true,
		boolean showPageNumbers=true,
		boolean showTitleInPage=true,
		boolean PDF,
		boolean HTML,
		boolean verbose=false
	) {
		// For testing, remove later
		pagePoolClear()
		ExportService = getInstance( 'ExportService@commandbox-gitbook' );
		bookService = getInstance( 'BookService@commandbox-gitbook' );
		// For testing, remove later

		arguments.sourcePath = resolvePath( arguments.sourcePath ?: '' );
		var actualSourcePath = arguments.sourcePath;
		
		arguments.targetDir = resolvePath( arguments.targetDir ?: '' );
		if( !'/,\'.listFindNoCase( targetDir.right( 1 ) ) ) {
			targetDir &= '/';
		}
		
		arguments.targetFile = arguments.targetFile ?: '';
		
		// Clean any accidental file extensions off the file name
		if( targetFile.len() && targetFile.listLen( '.' ) > 1 && 'pdf,html,mobi,epub'.listFindNoCase( targetFile.listLast( '.' ) ) ) {
			targetFile = targetFile.listDeleteAt( targetFile.listLen( '.' ), '.' );
		}
		 	
		var targetPathPartial = targetDir & targetFile;
		
		if( !isNull( arguments.pageheight ) && isNull( arguments.pagewidth ) ) {
			error( 'You cannot set a pageheight but not a pagewidth. Please provide both, or use a pre-defined pageType.' );
		}
		
		if( !isNull( arguments.pagewidth ) && isNull( arguments.pageheight ) ) {
			error( 'You cannot set a pagewidth but not a pageheight. Please provide both, or use a pre-defined pageType.' );
		}
		
		
		if( !isNull( arguments.pageheight ) || !isNull( arguments.pagewidth ) ) {
			arguments.pagetype='custom';
		}
		
		var cleanUpTemp = false;
		try {
	
			// This is sort of a dumb job step, just created it to have a wrapper since the PDF bit isn't in a service yet
			job.start( 'Processing' );
			job.setDumpLog( verbose );
					
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
	
			if( len( coverPageImageFile ) ) {
				coverPageImageFile = resolvepath( coverPageImageFile );
			}
			
			var renderOpts = {
				coverPageImageFile : coverPageImageFile,
				codeHighlighlightTheme : codeHighlighlightTheme,
				showTOC : showTOC,
				showPageNumbers : showPageNumbers,
				showTitleInPage : showTitleInPage
			};			
	
			var PDFOpts = {};
			var refArguments = arguments;
			'pageheight,pagewidth,pagetype,orientation,margintop,marginbottom,marginleft,marginright,unit'.listEach( ( p ) => {
				if( !isNull( refArguments[ p ] ) ) {
					PDFOpts[ p ] = refArguments[ p ];
				}
			} );
			var book = getInstance( 'BookExport@commandbox-gitbook' )
				.setSourcePath( actualSourcePath )
				.setExportVersion( version )
				.setTargetPathPartial( targetPathPartial )
				.setRenderOpts( renderOpts )
				.setPDFOpts( PDFOpts );
				
				
			// If nothing was specified, do all formats
			if( isNull( arguments.PDF ) && isNull( arguments.HTML ) ) {
				book.setCreatePDF( true ).setCreateHTML( true );
			// If at least one type was set to true, only do the true ones
			} else if( arguments.PDF ?: false || arguments.HTML ?: false ) {
				book.setCreatePDF( arguments.PDF ?: false ).setCreateHTML( arguments.HTML ?: false );
			// If none were set to true, but at least one type was set to false, only do the not-false ones.
			} else {
				book.setCreatePDF( arguments.PDF ?: true ).setCreateHTML( arguments.HTML ?: true );				
			}
				
			book.load();
			
			ExportService.exportAllTheThings( book );
			
		} finally {
			if( cleanUpTemp && directoryExists( actualSourcePath ) ) {
				directoryDelete( actualSourcePath, true );
			}
		}	

		job.complete();

		print
			.line()
			.greenLine( 'Complete!' )
			.line();
			
		if( book.getCreatePDF() ) {
			print.yellowLine( 'HTML written to #book.getHTMLExportFilePath()#' );
		}	
		if( book.getCreateHTML() ) {
			print.yellowLine( 'PDF written to #book.getPDFExportFilePath()#' );
		}
			
		
			
	
	}

	function versionsComplete() {
		try {
			return bookService.getVersions( resolvePath( '' ) );
		} catch( any e ) {
		}
	}

}
