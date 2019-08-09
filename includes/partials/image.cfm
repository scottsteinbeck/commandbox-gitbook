<cfoutput>
	<div class="image"> 
		<cfif node.data.keyExists('assetMeta')>
			<cfset fileName = BookService.getAssetUniqueName(node.data.assetMeta)>
			<!---<cfset photoBinary = fileReadBinary( '#bookDirectory#/resolvedAssets/#fileName#' ) />--->
			<img  align="center" style="max-width:100%" src="file:///#bookDirectory#/resolvedAssets/#fileName#" />
		</cfif>
		<div class="caption">#node.data.caption ?: ''#</div>
</div>
</cfoutput>