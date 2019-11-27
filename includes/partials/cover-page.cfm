<cfoutput><div style="text-align:center;padding:30px">
    <img src="#book.getLogo()#">
    <br />
    <h1 style="font-size: 40px;">#encodeForHTML( book.getTitle() )#</h1>
    <cfset coverVersion = book.getVersions().len() gt 1 ? book.getExportVersion() : ''>
    <cfif coverVersion is not "">
        <h3 style="font-size: 20px;">Version: #encodeForHTML( coverVersion )#</h3>
    </cfif>
    <div class="inside-page-break"></div>
</div></cfoutput>