<cfoutput>
<html>
    <title></title>
    <head>
    	<cfloop array="#node.data.styles#" item="style">
    		<style type="text/css">#style#</style>
    	</cfloop>
    </head>
    <body>
</cfoutput>