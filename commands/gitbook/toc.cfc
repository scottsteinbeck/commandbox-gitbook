/**
 * run the component to read out the table of contents 
 */
component {
    
    property name="configService" inject="configService";

    function run() {
        
        /**
         * Unzip file into a temp folder to work on it
         * TODO: will be a path specified by the user
         * TODO: move this into its own function
         */
        var sourcePath = expandPath('./gitbook-sample.zip');
        var tempDirectory = expandPath('./temp/')
        cfzip(action="unzip", file=sourcePath, destination=tempDirectory, overwrite="true");
        
        /**
         * Read version information from the revision.json file
         */
        var revisionFilePath = expandPath(tempDirectory & 'revision.json');
        if (fileExists(revisionFilePath)) {
            var revisionsJSONString = fileRead(revisionFilePath);
            var revisionsJSONObj = deserializeJSON(revisionsJSONString);

            if (structKeyExists(revisionsJSONObj, 'versions')) {
                var version = configService.getSetting('version','current')
                if(version == 'current') version = revisionsJSONObj.primaryVersionID;
                if(structKeyExists(revisionsJSONObj.versions,version)){
                    var tocTree = filterPageTitles(revisionsJSONObj.versions[version].page);
                    print.line(tocTree);
                }

            } else {
                print.boldText('No Versions');
            }
        } else {
            print.boldText('a revision.json file is not present in your Gitbook export file.');
        }
    }

    
    function filterPageTitles(required struct page){
        var subpages = page.pages.map(filterPageTitles);
        var pageData = {};
        pageData[page.title] = subpages;
        if( !arrayLen(subpages) ) return page.title;
        return pageData;
    }
    

}
