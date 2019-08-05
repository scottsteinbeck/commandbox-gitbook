/**
* I am the BookService and I handle getting basic data about a Gitbook from an export folder.
*/
component accessors="true"{
	
	function init(){		
		return this;
	}
	
	/**
	* Detect if the a directory contains a Gitbook export
	* 
	* @bookDirectory Absolute path to Gitbook
	*/
	function isBook( required string bookDirectory ){
		return fileExists( bookDirectory & '/revision.json' );		
	}

	/**
	* Get raw revision data from revisions.json
	* 
	* @bookDirectory Absolute path to Gitbook
	*/
	struct function getRevisionData( required string bookDirectory ){
		
		if( !isBook( bookDirectory ) ) {
			throw( message='This folder is not a Gitbook Export', detail=bookDirectory );
		}
		
    	return deserializeJSON( fileRead( bookDirectory & '/revision.json' ) );
	}

	/**
	* Get array of versions in a book
	* 
	* @bookDirectory Absolute path to Gitbook
	*/
	array function getVersions( required string bookDirectory ){
		return getRevisionData( bookDirectory )
			.versions
			.reduce( ( acc, k, v ) => acc.append( v.title ), [] );
	}

	/**
	* Get struct representing table contents for a version of the book
	* 
	* @bookDirectory Absolute path to Gitbook
	* @version A valid version in the this Gitbook
	*/
	array function getTOC( required string bookDirectory, required string version ){
		var revisionData = getRevisionData( bookDirectory );
        var TOCData = [];
	 
        if( version == 'current' ) {
        	version = revisionData.primaryVersionID;
        }
        
        if( revisionData.versions.keyExists( version ) ){
        	TOCData.append( [
        		'title' : revisionData.versions[ version ].page.title,
        		'type' : 'page',
        		'children' : []
        	] );
        	TOCData.append( filterPageTitles( revisionData.versions[ version ].page.pages ), true );
        }
        
        return TOCData;
	}


	/**
	* Resursive function for filtering page data 
	*/
    private function filterPageTitles(required array pages ){
        return pages.map( ( v ) => {
        	return [
        		'title' : v.title,
        		'type' : v.kind == 'document' ? 'page' : 'section',
        		'children' : filterPageTitles( v.pages )
        	];
        } );
    }

}