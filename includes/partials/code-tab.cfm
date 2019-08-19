<cfoutput>
<!--- 	<div class="code-tab"><pre>#innerContent#</pre></div> --->
<div class="code-tab">#rereplace(wirebox.getInstance( 'CodeFormatService@commandbox-gitbook' ).formatCodeBlock( innerContent, node.data.syntax ?: '', node.data.title ?: '' ),'>\s<','><','All')#</div>
</cfoutput>