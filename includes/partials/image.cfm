<cfoutput>
	<div class="image"> 
		<cfif node.data.keyExists('assetMeta')>
			<cfset fileName = BookService.getAssetUniqueName(node.data.assetMeta)>
			<cfset photoBinary = fileReadBinary( "resolvedAssets/#fileName#" ) />
			<img  align="center" style="max-width:100%" src="data:image/*;base64,#toBase64( photoBinary )#" />
		</cfif>
		<div class="caption">#node.data.caption ?: ''#</div>
</div>
</cfoutput>