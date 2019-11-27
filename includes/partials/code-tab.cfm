<cfoutput>
<cfset formattedCode = wirebox.getInstance( 'CodeFormatService@commandbox-gitbook' ).formatCodeBlock( innerContent, node.data.syntax ?: '', node.data.title ?: '' )>
<div class="code-tab">#formattedCode#</div>
</cfoutput>