<cfoutput>
	<cfif node.data.page.type == "page">
		<div class="section-header">#encodeForHTML( node.data.page.title )#</div>
	</cfif>
	<h2 id="#node.data.page.uid#" class="h1 #node.data.page.type#">#encodeForHTML( node.data.page.title )#</h2>
	#innerContent#
</cfoutput>