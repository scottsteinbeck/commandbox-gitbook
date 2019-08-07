<cfoutput>
	<li class="list-item #(node.data.keyExists('checked') ? 'list-item-check' : '')#">
		<cfif node.data.keyExists('checked') >
			<cfset checked = (node.data.checked == true ? 'checked="checked"' : '' )>
			<input type="checkbox" disabled="disabled" #checked# /> 
		</cfif>
		#innerContent#
	</li>
</cfoutput>