<cfoutput> 
	<!--- styles required inline for header and footer, the dont have access to the main styles	 --->
	<div class="footer" style="font-family: Arial, sans-serif;color: black;font-size: 12px;"> 
		<table width="100%">
			<tr>
				<td>
					<cfif book.getRenderOpts().showTitleInPage >
						#encodeForHTML( book.getTitle() )#
					</cfif>
				</td>
				<td align="right">
					<cfif book.getRenderOpts().showPageNumbers >
						#node.data.cfdocument.currentpagenumber#
					</cfif>
				</td>
			</tr>
		</table>
	</div>
</cfoutput>