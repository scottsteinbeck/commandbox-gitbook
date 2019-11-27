<cfoutput>
<cfset iconPath = pathToURL( expandPath( "/commandbox-gitbook/includes/icons/#node.data.style#.png" ) )>
<cfif moduleSettings['isOldPdfEngine']>
	<div class="hint hint-#node.data.style#">
		<table class="no-border">
			<tr>
				<td valign="top" style="padding: 4px 0px;">
					<cfif node.data.keyExists('style')>
						<img src="#iconPath#" width="30"/>
					</cfif>
				</td>
				<td>#innerContent#</td>
			</tr>
		</table>
	</div>
<cfelse>
	<div class="hint hint-#node.data.style#" style="background-image: url('#iconPath#')">
		#innerContent#
	</div>
</cfif>
</cfoutput>