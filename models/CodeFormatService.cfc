/**
 * I format code blocks
 */
component accessors="true" singleton {
	
	property name='fileSystemUtil' inject='FileSystem';
	
	property name='interpreter';

	function init() {
		variables.CR = server.separator.line;
		return this;
	}

	function onDiComplete() {
		fileSystemUtil.classLoad( expandPath( '/commandbox-gitbook/lib/' ) );
		setInterpreter( createObject( 'java', 'org.python.util.PythonInterpreter' ) ); 
	}

	/**
	 * Take a string and format it as HTML
	 */
	function formatCodeBlock( required string code, required string syntax, string fileName='' ) {
		
		getInterpreter().set("code", code );
		getInterpreter().set("fileName", fileName );
		
		var lexer = determimeLexer( syntax, code, fileName );
		
		getInterpreter().exec('from pygments import highlight#CR#' 
			& 'from pygments.lexers import #lexer##CR#'
			& 'from pygments.formatters import HtmlFormatter#CR#'
			& 'result = highlight(code, #lexer#(), HtmlFormatter( linenos="inline", filename=fileName ))');
	    		
		return getInterpreter().get("result", ''.getClass() )
	}


	private function determimeLexer( required string syntax, string code='', string fileName='' ) {
		
		// Pass out values into the Jython process
		getInterpreter().set("code", code );
		getInterpreter().set("syntax", syntax );
		getInterpreter().set("fileName", fileName );

		// Try to determine lexer by Gitbook syntax name if we have it
		if( len( syntax ) ) {
			try {
				getInterpreter().exec('from pygments.lexers import get_lexer_by_name#CR#'
					& 'result = get_lexer_by_name( syntax ).__class__.__name__');
			} catch( any e ) {
				// Classnotfound means Pygments coldn't find anything
				if( !e.getPageException().getRootCause().type.toString() contains 'pygments.util.ClassNotFound' ) {
					rethrow;
				}
			}
			
			// If we found something, return it.
			var result = getInterpreter().get("result", ''.getClass() );
			if( !isNull( result ) && len( result ) ) {
				return result;
			}
		}
		
		// Try to determine lexer by filename, if we have it and it looks to have a file extension in it
		if( len( fileName ) && listLen( fileName, '.' ) > 1 ) {
			try {
				getInterpreter().exec('from pygments.lexers import get_lexer_for_filename#CR#'
					& 'result = get_lexer_for_filename( fileName ).__class__.__name__');					
			} catch( any e ) {
				// Classnotfound means Pygments coldn't find anything
				if( !e.getPageException().getRootCause().type.toString() contains 'pygments.util.ClassNotFound' ) {
					rethrow;
				}
			}
			
			// If we found something, return it.
			var result = getInterpreter().get("result", ''.getClass() );
			if( !isNull( result ) && len( result ) ) {
				return result;
			}	
		}
		
		try {
			getInterpreter().exec('from pygments.lexers import guess_lexer#CR#'
				& 'result = guess_lexer( code ).__class__.__name__');					
		} catch( any e ) {
			// Classnotfound means Pygments coldn't find anything
			if( !e.getPageException().getRootCause().type.toString() contains 'pygments.util.ClassNotFound' ) {
				rethrow;
			}
		}
		
		// If we found something, return it.
		var result = getInterpreter().get("result", ''.getClass() );
		if( !isNull( result ) && len( result ) ) {
			return result;
		} else {
			return 'TextLexer';
		}
	    
	}

}
