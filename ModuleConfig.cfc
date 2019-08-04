component {

    this.title = 'Gitbok PDF';
    this.modelNamespace = 'commandbox-gitbookpdf';
    this.cfmapping = 'commandbox-gitbookpdf';

    function configure() {
        settings = {
            // Add a cover page to the beginning of the pdf
            'coverPagePath' : '',
            // Select a specific version or use 'current' to current one
            'version' : 'current',
            // Add Page Numbers to the pdf in the footer
            'pageNumbers' : true

        };
    }

}
