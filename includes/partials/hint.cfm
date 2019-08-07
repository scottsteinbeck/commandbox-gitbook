<cfoutput>
	<div class="hint hint-#node.data.style#">
		<cfset photoBinary = fileReadBinary(expandPath( "/commandbox-gitbook/includes/icons/#node.data.style#.png" )) />
		<img src="data:image/*;base64,#toBase64( photoBinary )#" />
		#innerContent#
	</div>
</cfoutput> 