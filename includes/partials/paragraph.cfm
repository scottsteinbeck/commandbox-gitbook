<cfif innerContent eq '---'>
    <div class="inner-page-break"></div>
<cfelseif len(DecodeforHTML(innerContent)) gt 0>
    <p><cfoutput>#innerContent#</cfoutput></p>
</cfif>
