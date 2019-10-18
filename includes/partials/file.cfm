<cfoutput> 
	<div class="file"> 
		<table class="no-border">
			<tr>
				<td><div class="file-caption">#encodeForHTML( node.data?.caption ?: '' )#</div></td>
				<td align="right"><a  class="file-name" href="#node.data.assetMeta.downloadURL#">#encodeForHTML( node.data.assetMeta.name )#</a></td>
			</tr>
		</table>
	</div>
</cfoutput>