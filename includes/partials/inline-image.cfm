<cfoutput>
	<span class="image"> 
		<cfif node.data.keyExists('assetMeta')>
			<cfset fileName = BookService.getAssetUniqueName(node.data.assetMeta)>
			<img  align="center" style="max-width:100%" src="file:///#book.getSourcePath()#/resolvedAssets/#fileName#" alt="#node.data?.caption ?: ''#" />
		<cfelseif node.data.keyExists( 'src' )>
			<!--- Acquire external image, resize, and cache it for later use. --->
			<cfset localpath = "#book.getSourcePath()#/resolvedAssets/#node.key#-#listLast( node.data.src, '/\' ).listFirst( '?' )#">
			<cfif not fileExists( localpath )>
				<cfset job.addLog( 'Downloading #node.data.src#' )>
				<cfset bookService.acquireExternalAsset( node.data.src, localpath )>
				<cfset bookService.resizeImage( localpath )>
			</cfif>
			<img  align="center" style="max-width:100%" src="file:///#localpath#" alt="#node.data?.caption ?: ''#" />
		</cfif>
	</span>
</cfoutput>