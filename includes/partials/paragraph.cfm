<cfoutput>
	<cfif node.data.parentData.keyExists('style')>
		<cfset photoBinary = fileReadBinary(expandPath( "/commandbox-gitbook/includes/icons/#node.data.parentData.style#.png" )) />
		<cfset innerContent = '<img src="data:image/*;base64,#toBase64( photoBinary )#" width="32"/>' & innerContent>		
	</cfif>
<cfif len(DecodeforHTML(innerContent)) gt 0><p>#innerContent#</p></cfif>
</cfoutput>