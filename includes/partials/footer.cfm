<cfoutput> 
	<!--- styles required inline for header and footer, the dont have access to the main styles	 --->
	<div class="footer" style="font-family: Arial, sans-serif;color: black;font-size: 12px;"> 
		<table width="100%">
			<tr>
				<td>#node.data.title#</td>
				<td align="right">#node.data.cfdocument.currentpagenumber#</td>
			</tr>
		</table>
	</div>
</cfoutput>