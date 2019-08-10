<cfoutput>
<!--- Broken for lucee	<cfif node.data.keyExists('pageID')><cfset node.data.href="###node.data.pageID#"></cfif> ---> 
	<span class="link"><a href="#(node.data.href ?: false)#" target="_blank">#replace(wrap(innerContent,90), chr(10), "<wbr/>", "all")#</a></span>
</cfoutput>