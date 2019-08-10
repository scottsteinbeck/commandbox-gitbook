<cfoutput>
	<div class="image"> 
		<cfif node.data.keyExists('assetMeta')>
			<cfset fileName = BookService.getAssetUniqueName(node.data.assetMeta)>
			<img  align="center" style="max-width:100%" src="file:///#bookDirectory#/resolvedAssets/#fileName#" />
		<cfelseif node.data.keyExists( 'src' )>
			<!--- Acquire external image, resize, and cache it for later use. --->
			<cfset localpath = "#bookDirectory#/resolvedAssets/#node.key#-#listLast( node.data.src, '/\' )#">
			<cfif not fileExists( localpath )>
				<cfset job.addLog( 'Downloading #node.data.src#' )>
				<cfset bookService.acquireExternalAsset( node.data.src, localpath )>
				<cfset bookService.resizeImage( localpath )>
			</cfif>
			<img  align="center" style="max-width:100%" src="file:///#localpath#" />
		</cfif>
		<div class="caption">#node.data.caption ?: ''#</div>
</div>
</cfoutput>