component {

	this.title = 'Gitbok PDF Exporter';
	this.modelNamespace = 'commandbox-gitbook';
	this.cfmapping = 'commandbox-gitbook';

	function configure() {

		//Checking Lucee version to determine if its bundled with the old (pd4ml engine ) or new (Flying Saucer Engine)
		var oldPdfEngine = false;
		if(listFirst( server.lucee.version, '.' ) == 5 && listGetAt( server.lucee.version, 2, '.' ) lt 3){
			oldPdfEngine = true;
		}
		settings = {
			'isOldPdfEngine': oldPdfEngine
		};
	}

}
