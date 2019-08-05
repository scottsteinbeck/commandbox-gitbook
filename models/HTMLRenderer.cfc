/**
* I render HTML for a book
*/
component accessors="true"{
	
    property name="bookService" inject="BookService@commandbox-gitbook";
    
	function init(){		
		return this;
	}
	
	/**
	* 
	* 
	* @bookDirectory Absolute path to Gitbook
	* @version A valid version in the this Gitbook
	*/
	function renderBook( required string bookDirectory, required string version ){
		var TOCData = bookService.getTOC( bookDirectory, version );
        var bookHTML = '';
        
        if( version == 'current' ) {
        	version = bookService.getCurrentVersion( bookDirectory );
        }
                
        var renderChildren = function( tree ) {
        	tree.each( ( child ) => {
        		if( child.type == 'section' ) {
        			// renderSection();
        			bookHTML &= '<hr><h1>#child.title#</h1><hr>';
        		} else if ( child.type == 'page' ) {
        			bookHTML &= renderPage( bookDirectory & '/versions/#version#/#child.path#.json' );
        		}
       			renderChildren( child.children );
        	} );
        };
        
        renderChildren( TOCData );
        
        return bookHTML;
	}
	
	function renderpage( string JSONPath ) {
		var pageJSON = deserializeJSON( fileRead( JSONPath ) );
		
		return renderNode( pageJSON.document );
		
	}
	
	function renderNode( required struct node ) {
		var innerContent = ( node.nodes ?: [] ).map( renderNode ).tolist( ' ' );
		if( node.kind == 'document' ) {
			return renderPartial( 'document', node, innerContent );
		} else if( node.kind == 'text' ) {
			return renderTextRanges( node.ranges );
		} else if( node.kind == 'block' ) {
			return renderPartial( node.type, node, innerContent );
		} 
	}
	
	function renderTextRanges( ranges ) {
		return ranges.map( ( r ) => {
			var thisText = encodeForHTML( r.text );
			r.marks.each( ( m ) => {
				thisText = renderPartial( 'mark-#m.type#', m, thisText );
			} );
			return thisText;
		} ).toList( '' );
	}
	
	function renderPartial( required string template, struct node, string innerContent ) {
		template = '/commandbox-gitbook/includes/partials/' & template & '.cfm';
		
		if( !fileExists( template ) ) {
			return '<div class="missing-element-type">#innerContent#</div>';
		}
		
		saveContent variable="local.HTML" {
			include template;
		}
		return local.HTML
	}
	
}