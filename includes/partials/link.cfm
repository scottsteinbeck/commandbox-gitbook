<cfoutput>
	<span class="link"><a href="#(node.data.href ?: false)#" target="_blank">#replace(wrap(innerContent,90), chr(10), "&##8203;", "all")#</a></span>
</cfoutput>