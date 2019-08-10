<cfoutput>
	<div class="hint hint-#node.data.style#">
		<table class="no-border">
			<tr>
				<td valign="top" style="padding: 4px 0px;">	
					<cfif node.data.keyExists('style')>
						<cfset photoBinary = fileReadBinary(expandPath( "/commandbox-gitbook/includes/icons/#node.data.style#.png" )) />
						<img src="data:image/*;base64,#toBase64( photoBinary )#" width="30"/>		
					</cfif>		
				</td>
				<td>#innerContent#</td>
			</tr>
		</table>
		
	</div>
</cfoutput> 