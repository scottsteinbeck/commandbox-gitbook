<cfoutput>
	<div class="image">
		<img align="center" src="#(node.data.assetMeta.downloadURL ?: '')#"><div class="caption">#node.data.caption ?: ''#</div>
	</div>
</cfoutput>
