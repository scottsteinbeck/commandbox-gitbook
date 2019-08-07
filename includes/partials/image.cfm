<cfoutput>
	<div class="image"> 
		<cfset fileName = BookService.getAssetUniqueName(node.data.assetMeta)>
		<cfset photoBinary = fileReadBinary( "resolvedAssets/#fileName#" ) />
		<img  align="center" width="100%" src="data:image/*;base64,#toBase64( photoBinary )#" />
		<div class="caption">#node.data.caption ?: ''#</div>
</div>
</cfoutput>