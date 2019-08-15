<cfoutput>
	<div class="hint hint-#node.data.style#">
		<table class="no-border">
			<tr>
				<td valign="top" style="padding: 4px 0px;">	
					<cfif node.data.keyExists('style')>
						<img src="file:///#expandPath( "/commandbox-gitbook/includes/icons/#node.data.style#.png" )#" width="30"/>		
					</cfif>		
				</td>
				<td>#innerContent#</td>
			</tr>
		</table>
		
	</div>
</cfoutput> 