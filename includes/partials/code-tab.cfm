<cfoutput>
<!--- 	<div class="code-tab"><pre>#innerContent#</pre></div> --->
<div class="code-tab">#wirebox.getInstance( 'CodeFormatService@commandbox-gitbook' ).formatCodeBlock( innerContent, node.data.syntax ?: '', node.data.title ?: '' )#</div>
</cfoutput>