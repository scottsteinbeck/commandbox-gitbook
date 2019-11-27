<cfoutput>
	<div class="code">
		<cfif arrayLen(node.nodes) && node.nodes[1].type == "code-line">
			<cfset formattedCode = wirebox.getInstance( 'CodeFormatService@commandbox-gitbook' ).formatCodeBlock( innerContent, node.data.syntax ?: '', node.data.title ?: '' )>
			#formattedCode#
		<cfelse>
			#innerContent#
		</cfif>
	</div>
</cfoutput>