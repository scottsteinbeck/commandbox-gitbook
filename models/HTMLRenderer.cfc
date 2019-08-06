/**
 * I render HTML for a book
 */
component accessors="true" {

	property name="bookService" inject="BookService@commandbox-gitbook";
	property name="wirebox" inject="wirebox";

	function init() {
		return this;
	}

	/**
	 *
	 *
	 * @bookDirectory Absolute path to Gitbook
	 * @version A valid version in the this Gitbook
	 */
	function renderBook( required string bookDirectory, required string version ) {
		var TOCData = bookService.getTOC( bookDirectory, version );
		var AssetCollection = bookService.getAssets( bookDirectory, version );
		var bookHTML = '<style type="text/css">#fileRead( expandPath( '/commandbox-gitbook/includes/styles.css' ) )#</style>';
		bookHTML &= '<style type="text/css">#fileRead( expandPath( '/commandbox-gitbook/includes/pygments/default.css' ) )#</style>';

		if( version == 'current' ) {
			version = bookService.getCurrentVersion( bookDirectory );
		}

		var renderChildren = function(tree) {
			tree.each( (child) => {
				bookHTML &= '<h1 class="#child.type#">#child.title#</h1>';
				if( child.type == 'page' ) {
					bookHTML &= renderPage( bookDirectory & '/versions/#version#/#child.path#.json', AssetCollection );
				}
				renderChildren( child.children );
			} );
		}
		;

		renderChildren( TOCData );

		return renderPartial( 'body-wrapper', { 'data': {} }, bookHTML );
		
	}

	function renderpage( string JSONPath, struct AssetCollection ) {
		var pageJSON = deserializeJSON( fileRead( JSONPath ) );

		return renderNode( pageJSON.document, AssetCollection );
	}

	function renderNode( required struct node, struct AssetCollection, boolean raw=false ) {
		var innerContent = ( node.nodes ?: [] ).map( (node) => {
				return renderNode( 
					node,
					AssetCollection,
					// Don't escape HTML if this is a code line, or are ancenstor was one
					raw || ( node.type ?: '' ) == 'code-line' )
			} ).tolist( '' );
			
		if( node.kind == 'document' ) {
			return renderPartial( 'document', node, innerContent );
		} else if( node.kind == 'text' ) {
			return renderTextRanges( node, raw );
		} else if( node.kind == 'block' || node.kind == 'inline' ) {
			return renderPartial(
				node.type,
				node,
				innerContent,
				AssetCollection				
			// Block elements need a line break. This is important for code blocks that are in a pre tag.
			) & ( node.kind == 'block' ? chr(13) & chr(10) : '' );
		}
	}

	function renderTextRanges( node, raw=false ) {
		return node.ranges
			.map( (r) => {
				// Code lines are preformatted so don't escape them
				if( raw ) {
					var thisText = r.text;
					if(thisText.len() > 85) thisText = wrap(thisText,85);
				} else {
					var thisText = encodeForHTML( r.text );
				}
				r.marks.each( (m) => {
					thisText = renderPartial( 'mark-#m.type#', m, thisText );
				} );
				return thisText;
			} )
			.toList( '' );
	}



	function renderPartial(
		required string template,
		struct node,
		string innerContent,
		struct AssetCollection = {}
	) {
		if( node.data.keyExists( 'assetID' ) ) node.data.assetMeta = AssetCollection[ node.data.assetID ];

		template = '/commandbox-gitbook/includes/partials/' & template & '.cfm';

		if( !fileExists( template ) ) {
			return '<div class="missing-element-type">[ #node.type# ] #innerContent#</div>';
		}

		saveContent variable="local.HTML" {
			include template;
		}
		return local.HTML
	}

}
