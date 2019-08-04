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
	struct function getTOC( required string bookDirectory, required string version ){
		var revisionData = getRevisionData( bookDirectory );
	 
        if( version == 'current' ) {
        	version = revisionData.primaryVersionID;
        }
        
        if( revisionData.versions.keyExists( version ) ){
            return filterPageTitles( revisionData.versions[ version ].page );
        }
        
        return {};
	}


	/**
	* Resursive function for filtering page data 
	*/
    private function filterPageTitles(required struct page){
        var subpages = page.pages.map(filterPageTitles);
        var pageData = {};
        pageData[ page.title ] = subpages;
        if( !subpages.len() ) return page.title;
        return pageData;
    }

}