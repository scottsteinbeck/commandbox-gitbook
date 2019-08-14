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
	 */
	function exportAllTheThings( required book ) {
		
		// Generate array of HTML strings representing book
		buildBookHTML( book );

		if( book.getCreatePDF() ) {
			renderBookPDF( book );
		}
		
		if( book.getCreateHTML() ) {
			renderBookHTML( book );			
		}
		
	}

	/**
	 * Return array of strings representing HTML of each book page
	 *
	 */
	function buildBookHTML( required book ) {
		job.start( 'Render Book as HTML' );

		var bookLogo = book.getLogo();
		
		job.start( 'Build Table Of Contents' );
			var TOCData = book.getTOC();
		job.complete();
		
		bookService.resolveAssetsToDisk( book )
		var pages = [];

		if( book.getRenderOpts().coverPageImageFile.len() ) {
			pages.append(
				renderPartial( 'cover-page-image', { data : { coverPageImageFile : book.getRenderOpts().coverPageImageFile } }, '', book )
			);
		} else {
			pages.append(
				renderPartial( 'cover-page', { data : {} }, '', book )
			);	
		}
		if( book.getRenderOpts().showTOC ) {
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
						renderPage( child.path, book )
					);
					progressBarGeneric.update(
						percent = ( currentCount / totalPages ) * 100,
						currentCount = currentCount,
						totalCount = totalPages
					);
				}
				renderChildren( child.children );
			} );
		};


		renderChildren( TOCData );

		progressBarGeneric.clear();

		job.complete();

		job.complete();

		book.setPages( pages );
		
		book.setBodyWrapperTop( renderPartial(
			'body-wrapper-top',
			{
				'data' : {
					styles : [
						fileRead( expandPath( '/commandbox-gitbook/includes/pygments/#book.getRenderOpts().codeHighlighlightTheme#.css' ) ),
						// TODO: add user styles by convention such that they override built in styles
						fileRead( expandPath( '/commandbox-gitbook/includes/styles.css' ) )
					]
				}
			},
			'',
			book
		) );
		
		book.setBodyWrapperBottom( renderPartial( 'body-wrapper-bottom', { 'data' : {} }, '', book ) );
				
	}

	function renderBookHTML( book ) {
		job.start( 'Building HTML' );
		job.addLog( 'Writing HTML to #book.getHTMLExportFilePath()#' );
		
		// Write HTML output
		fileWrite( book.getHTMLExportFilePath(), book.getBodyWrapperTop() & book.getPages().toList( ' ' ) & book.getBodyWrapperBottom() );
		
		job.complete();
	}

	
		


	/**
	 *
	 *
	 */
	function renderBookPDF( book ) {
		job.start( 'Building PDF' );
		job.addLog( 'Writing PDF to #book.getPDFExportFilePath()#' );

		document format='pdf'
     			filename=book.getPDFExportFilePath()
     			overwrite=true
     			bookmark=true
     			localurl=true
     			attributeCollection=book.getPDFOpts() {
     				
			documentSection {
					
				documentitem type='header' evalAtPrint=true { echo( '' ); }
				documentitem type='footer' evalAtPrint=true { echo( '' ); }
		 				
				echo( book.getBodyWrapperTop() );
				echo( book.getPages()[ 1 ] );
				echo( book.getBodyWrapperBottom() );
			}
			
			documentSection {
						
				echo( book.getBodyWrapperTop() );
				
				documentitem type='header' evalAtPrint=true {
					echo( renderPartial( 'header', { 'data' : { cfdocument : cfdocument } }, '', book ) );
				}
				// Putting this inside of a section breaks the page numbering due to Lucee bug
				documentitem type='footer' evalAtPrint=true {
					echo( renderPartial( 'footer', { 'data' : { cfdocument : cfdocument } }, '', book ) );
				}
				
				var counter = 0;
				for( var page in book.getPages() ) {
					counter++;
					if( counter > 1 ) {
						echo( page );
					}
				}
				echo( book.getBodyWrapperBottom() );
			}
		}

		job.complete();
		
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
			TOCContent &= '<li><p>#child.title#';
			if( child.children.len() ) TOCContent &= generateTOCNode( child.children );
			TOCContent &= '</p></li>';
		} );
		TOCContent &= '</ul>';
		return TOCContent;
	}

	function renderPage( required string pageName, required book ) {
		var pageJSON = book.getPageJSON( pageName );
		return !isNull( pageJSON ) ? renderNode( pageJSON.document, book ) : '';
	}

	function renderNode( required struct node, book, boolean raw = false ) {
		var innerContent = ( node.nodes ?: [] )
			.map( (node) => {
				return renderNode(
					node,
					book,
					// Don't escape HTML if this is a code line, or are ancenstor was one
					raw || ( node.type ?: '' ) == 'code-line'
				)
			} )
			.tolist( '' );

		if( node.kind == 'document' ) {
			return renderPartial( 'document', node, innerContent, book );
		} else if( node.kind == 'text' ) {
			return renderTextRanges( node, book, raw );
		} else if( node.kind == 'block' || node.kind == 'inline' ) {
			return renderPartial(
				node.type,
				node,
				innerContent,
				book
			// Block elements need a line break. This is important for code blocks that are in a pre tag.
			) & ( node.kind == 'block' ? chr( 13 ) & chr( 10 ) : '' );
		}
	}

	function renderTextRanges( node, book, raw = false ) {
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
					thisText = trim( renderPartial( 'mark-#m.type#', m, thisText, book ) );
				} );
				return thisText;
			} )
			.toList( '' );
	}



	function renderPartial(
		required string template,
		struct node,
		string innerContent = '',
		required book
	) {
		if( node.data.keyExists( 'assetID' ) ) node.data.assetMeta = book.getAssets()[ node.data.assetID ];

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
