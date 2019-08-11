<cfoutput>
<!--- Broken for lucee	<cfif node.data.keyExists('pageID')><cfset node.data.href="###node.data.pageID#"></cfif> ---> 
	<span class="link"><a href="#(node.data.href ?: false)#" target="_blank">#innerContent#</a></span>
</cfoutput>