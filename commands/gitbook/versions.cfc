/**
 * run the component to unpack and read a gitbook export
 */
component {

    function run() {
        
        /**
         * Unzip file into a temp folder to work on it
         * TODO: will be a path specified by the user
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
                var revisionList = structKeyArray(revisionsJSONObj.versions);
                print.boldTextLine('Version List');
                revisionList.map(function(tag) {
                    print.indentedLine(revisionsJSONObj.versions[tag].title);
                });
            } else {
                print.boldText('No Versions');
            }
        } else {
            print.boldText('a revision.json file is not present in your Gitbook export file.');
        }
    }

}
