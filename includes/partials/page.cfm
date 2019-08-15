<cfoutput>
	<h1 id="#node.data.page.uid#" class="#node.data.page.type#">#encodeForHTML( node.data.page.title )#</h1>
	#innerContent#
</cfoutput>