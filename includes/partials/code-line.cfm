<cfoutput>
	<div class="code-line">
		<cfif len(innerContent)) gt 85>
			<pre>#wrap(innerContent),85)#</pre>
		<cfelse>
			<pre>#innerContent#</pre>
		</cfif></div>
</cfoutput>
