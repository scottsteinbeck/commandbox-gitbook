<!--- Small UDF to help output TOC items --->
<cffunction name="generateTOCNode" output="true">
	<cfargument name="TOCData">
	<cfargument name="depth" default="0">

	<ul class="<cfif depth eq 0>toc</cfif>">
	<cfset var subDepth = depth + 1>
	<cfloop array="#TOCData#" item="local.child" >
		<li class="d_#depth#"><a href="###child.uid#" class="d_#depth#">#encodeForHTML( child.title )#</a>
		<cfif child.children.len() >
			#generateTOCNode( child.children, subDepth )#
		</cfif>
		</li>
	</cfloop>
	</ul>
</cffunction>
<cfoutput>
	<div class="document toc">
		<div class="page h1">Table of Contents</div>
		<cfif moduleSettings['isOldPdfEngine']>
			<br>
			<pd4ml:toc/>
		</cfif>
		<cfset generateTOCNode( node.data.TOCData , 0 )>
	</div>
</cfoutput>