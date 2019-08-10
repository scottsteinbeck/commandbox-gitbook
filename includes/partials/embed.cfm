<cfoutput>
	<cfif node.data.keyExists( 'url' ) >
		<cfset embedData = bookService.resolveURLEmbedData( node.data.url )>
		<div class="embed">
			<div class="embed-title">
				#encodeForHTML( embedData.pageTitle )#
			</div>
			<span class="link"><a href="#embedData.embedURL#" target="_blank">#embedData.embdedHost#</a></span>
		</div>
	<cfelse>
		Unnknown embed type!<br>
		node.data: #serializeJSON( node.data )#
	</cfif>
</cfoutput>