/**
* I render HTML for a book
*/
component accessors="true"{
	
	function init(){		
		return this;
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