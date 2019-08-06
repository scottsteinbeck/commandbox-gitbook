<cfoutput>
	<div class="code-line">
		<cfif len(decodeForHTML(innerContent)) gt 85>
			<pre>#wrap(decodeForHTML(innerContent),85)#</pre>
		<cfelse>
			<pre>#innerContent#</pre>
		</cfif></div>
</cfoutput>