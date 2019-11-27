<!DOCTYPE html>
<cfoutput>
<html>
	<head>
		<title><cfif book.getRenderOpts().showTitleInPage >#encodeForHTML( book.getTitle() )#</cfif></title>
		<meta charset="UTF-8">
    </head>
	<body>
		<div id="pageTitle"><cfif book.getRenderOpts().showTitleInPage >#encodeForHTML( book.getTitle() )#</cfif></div>
		<cfif moduleSettings['isOldPdfEngine']>
			<pd4ml:page.footer scope="2+"  style="display: none; visibility: hidden; pd4ml-display: block; pd4ml-visibility: visible">
			<div class="footer" style="font-family: Arial, sans-serif;color: ##999;font-size: 12px;">
				<pd4ml:page.foot width="100%">
				<table width="100%">
					<tr>
						<td style="border:none">
							<cfif book.getRenderOpts().showTitleInPage >
								#encodeForHTML( book.getTitle() )#
							</cfif>
						</td>
						<td align="right" style="border:none">
							$[page] of $[total]
						</td>
					</tr>
				</table>
			</div>
		</pd4ml:page.footer>
	</cfif>
	<cfloop array="#node.data.styles#" item="style">
		<style type="text/css">#style#</style>
	</cfloop>
	</cfoutput>
