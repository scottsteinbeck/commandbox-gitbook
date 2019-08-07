<cfoutput>
	<div class="api-method-parameter">
		<table class="param-table">
			<tr>
				<td width="20%">
					<div class="param-name">#node.data.name#</div>
					<div class="param-required param-required-#(node.data.required ?: false)#">#((node.data.required ?: false) ? "REQUIRED" : "OPTIONAL")#</div>
				</td>
				<td width="20%"><div class="param-type">#node.data.type#</div></td>
				<td width=""><div class="param-desc">#innerContent#</div></td> 
			</tr>
		</table>
	</div>
</cfoutput>