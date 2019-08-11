<cfoutput><div style="text-align:center;padding:30px;page-break-after:always">
    <img src="#node.data.logo#">
    <br />
    <h1 style="font-size: 40px;">#node.data.title#</h1>
    <cfif node.data.version is not "">
        <h3 style="font-size: 20px;">Version: #node.data.version#</h3>
    </cfif>
    <div class="inside-page-break"></div>
</div></cfoutput>