<!--- Small UDF to help output TOC items --->
<cffunction name="generateTOCNode" output="true">
	<cfargument name="TOCData">
	<cfargument name="depth" default="0">
	
	<ul>
	<cfset var subDepth = depth + 1> 
	<cfloop array="#TOCData#" item="local.child" >
		<li class="d_#depth#"><div class="d_#depth#">#child.title#</div>
		<cfif child.children.len() >
			 #generateTOCNode( child.children, subDepth )#
		</cfif>
		</li>
	</cfloop>
	</ul>
</cffunction>
<cfoutput>
	<div class="document toc">
		<h1 class="page">Table of Contents</h1>
		<cfset generateTOCNode( node.data.TOCData , 0 )>
	</div>
</cfoutput>