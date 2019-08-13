/**
 * I render HTML for a book
 */
component accessors='true' {

	property name='bookService' inject='BookService@commandbox-gitbook';
	property name='wirebox' inject='wirebox';
	property name='job' inject='interactiveJob';
	property name='progressBarGeneric' inject='progressBarGeneric';
	property name='FilesystemUtil' inject='Filesystem';

	processingdirective pageEncoding='UTF-8';

	function init() {
		return this;
	}

	/**
	 *
	 *
	 * @bookDirectory Absolute path to Gitbook
	 * @version A valid version in the this Gitbook
	 */
	function renderBookPDF( required string bookDirectory, required string version, struct renderOpts={}, struct PDFOpts={} ) {
		
		renderOpts.coverPageImageFile = renderOpts.coverPageImageFile ?: '';
		renderOpts.codeHighlighlightTheme = renderOpts.codeHighlighlightTheme ?: 'default';
		renderOpts.showTOC = renderOpts.showTOC ?: true;
		renderOpts.showPageNumbers = renderOpts.showPageNumbers ?: true;
		
		var bookTitle = bookService.getBookTitle( bookDirectory );
		var bodyTop = renderPartial(
			'body-wrapper-top',
			{
				'data' : {
					styles : [
						// TODO: make this configurable
						fileRead( expandPath( '/commandbox-gitbook/includes/pygments/#renderOpts.codeHighlighlightTheme#.css' ) ),
						// TODO: add user styles by convention such that they override built in styles
						fileRead( expandPath( '/commandbox-gitbook/includes/styles.css' ) )
					]
				}
			}
		);

		var bodyBottom = renderPartial( 'body-wrapper-bottom', { 'data' : {} } );

		var pages = renderBook( bookDirectory, version, renderOpts );

		fileWrite( filesystemUtil.resolvePath( 'test.html' ), bodyTop & pages.toList( ' ' ) & bodyBottom );

		job.start( 'Building PDF' );
		job.addLog( 'Writing PDF to #filesystemUtil.resolvePath( 'test.pdf' )#' );
		document format='pdf'
     			filename=filesystemUtil.resolvePath( 'test.pdf' )
     			overwrite=true
     			bookmark=true
				localurl=true
				attributeCollection=PDFOpts
     			{
     				
			documentSection attributeCollection=PDFOpts{
					
				documentitem type='header' evalAtPrint=true {
					echo( '' );
				}
				documentitem type='footer' evalAtPrint=true {
					echo( '' );
				}
		 				
				echo( bodyTop );
			
				echo( pages[ 1 ] );
				
				echo( bodyBottom );
			}
			
			documentSection attributeCollection=PDFOpts{
						
				echo( bodyTop );
				
				documentitem type='header' evalAtPrint=true {
					echo( renderPartial( 'header', { 'data' : { cfdocument : cfdocument, title : bookTitle, showPageNumbers : renderOpts.showPageNumbers } } ) );
				}
				// Putting this inside of a section breaks the page numbering due to Lucee bug
				documentitem type='footer' evalAtPrint=true {
					echo( renderPartial( 'footer', { 'data' : { cfdocument : cfdocument, title : bookTitle, showPageNumbers : renderOpts.showPageNumbers } } ) );
				}
				
				var counter = 0;
				for( var page in pages ) {
					counter++;
					if( counter > 1 ) {
						echo( page );
					}
				}
				echo( bodyBottom );
			}
		}

		job.complete();
	}

	/**
	 *
	 *
	 * @bookDirectory Absolute path to Gitbook
	 * @version A valid version in the this Gitbook
	 */
	function renderBook( required string bookDirectory, required string version, struct renderOpts ) {
		// I hate this, but I don't feel like passing this down 37 methods just to make it avaialble to the partials
		variables.bookDirectory = arguments.bookDirectory;
		job.start( 'Render Book as HTML' );

		var bookTitle = bookService.getBookTitle( bookDirectory );
		var bookLogo = bookService.getBookLogo( bookDirectory );
		var TOCData = bookService.getTOC( bookDirectory, version );
		var AssetCollection = bookService.getAssets( bookDirectory );
		bookService.resolveAssetsToDisk( bookDirectory, bookDirectory & '/resolvedAssets' )
		var pages = [];

		if( version == 'current' ) {
			version = bookService.getCurrentVersion( bookDirectory );
		}
		var coverVersion = bookService.getBookVersionTitle( bookDirectory, version );

		if( renderOpts.coverPageImageFile.len() ) {
			pages.append(
				renderPartial( 'cover-page-image', { data : { coverPageImageFile : renderOpts.coverPageImageFile } } )
			);
		} else {
			pages.append(
				renderPartial( 'cover-page', { data : { title : bookTitle, version : coverVersion, logo : bookLogo } } )
			);	
		}
		if( renderOpts.showTOC ) {
			pages.append( renderTableOfContents( TOCData ) );
		}

		job.start( 'Render Pages' );

		var countChildren = function(tree) {
			var thisCount = 0;
			tree.each( (child) => {
				if( child.type == 'page' ) {
					thisCount++;
				}
				thisCount += countChildren( child.children );
			} );
			return thisCount;
		}
		;
		var totalPages = countChildren( TOCData );
		var currentCount = 0;
		progressBarGeneric.update( percent = 0, currentCount = 0, totalCount = totalPages );

		var renderChildren = function(tree) {
			tree.each( (child) => {
				job.addLog( child.title );
				pages.append( '<h1 id="#child.uid#" class="#child.type#">#child.title#</h1>' );
				if( child.type == 'page' ) {
					currentCount++;
					pages.append(
						renderPage( bookDirectory & '/versions/#version#/#child.path#.json', AssetCollection )
					);
					progressBarGeneric.update(
						percent = ( currentCount / totalPages ) * 100,
						currentCount = currentCount,
						totalCount = totalPages
					);
				}
				renderChildren( child.children );
			} );
		}
		;


		renderChildren( TOCData );

		progressBarGeneric.clear();

		job.complete();

		job.complete();

		return pages
	}

	string function renderTableOfContents( array TOCNodes ) {
		var TOCPage = '<div class="document">';
		TOCPage &= '<h1 class="page">Table of Contents</h1>';
		TOCPage &= generateTOCNode( TOCNodes );
		TOCPage &= '</div>';
		return TOCPage;
	}

	string function generateTOCNode( array TOCNodes ) {
		var TOCContent = '<ul>';
		TOCNodes.each( (child) => {
			TOCContent &= '<li>#child.title#';
			if( child.children.len() ) TOCContent &= generateTOCNode( child.children );
			TOCContent &= '</li>';
		} );
		TOCContent &= '</ul>';
		return TOCContent;
	}

	function renderPage( string JSONPath, struct AssetCollection ) {
		var pageJSON = bookService.retrieveJSON( JSONPath );
		return isStruct( pageJSON ) ? renderNode( pageJSON.document, AssetCollection ) : '';
	}

	function renderNode( required struct node, struct AssetCollection, boolean raw = false ) {
		var innerContent = ( node.nodes ?: [] )
			.map( (node) => {
				return renderNode(
					node,
					AssetCollection,
					// Don't escape HTML if this is a code line, or are ancenstor was one
					raw || ( node.type ?: '' ) == 'code-line'
				)
			} )
			.tolist( '' );

		if( node.kind == 'document' ) {
			return renderPartial( 'document', node, innerContent );
		} else if( node.kind == 'text' ) {
			return renderTextRanges( node, raw );
		} else if( node.kind == 'block' || node.kind == 'inline' ) {
			return renderPartial(
				node.type,
				node,
				innerContent,
				AssetCollection // Block elements need a line break. This is important for code blocks that are in a pre tag.
			) & ( node.kind == 'block' ? chr( 13 ) & chr( 10 ) : '' );
		}
	}

	function renderTextRanges( node, raw = false ) {
		return node.ranges
			.map( (r) => {
				// Fix for weird "zero width html code &zwnj;" causing style issues in PDF
				var thisText = replace( r.text, chr( 8203 ), '', 'all' );
				thisText = replace( thisText, chr( 8204 ), '', 'all' );
				
				if( raw ) {
					// Code lines are preformatted so don't escape them
					thisText = thisText
				} else {
					thisText = encodeForHTML( thisText );
				}
				r.marks.each( (m) => {
					thisText = trim( renderPartial( 'mark-#m.type#', m, thisText ) );
				} );
				return thisText;
			} )
			.toList( '' );
	}



	function renderPartial(
		required string template,
		struct node,
		string innerContent = '',
		struct AssetCollection = {}
	) {
		if( node.data.keyExists( 'assetID' ) ) node.data.assetMeta = AssetCollection[ node.data.assetID ];

		template = '/commandbox-gitbook/includes/partials/' & template & '.cfm';

		if( !fileExists( template ) ) {
			return '<div class="missing-element-type">[ #node.type# ] #innerContent#</div>';
		}

		saveContent variable='local.HTML' {
			include template;
		}
		return local.HTML
	}

}
