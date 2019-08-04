<cfset name = getMetaKey('name')>
<cfset type = getMetaKey('type')>
<cfset required = getMetaKey('required')>

<div class="api-method-parameter">
    <table class="paramTable">
        <tr>
            <td width="100">
                <div class="valDesc">Name</div>
                #name#&nbsp;
            </td>
            <td width="100">
                <div class="valDesc">Type</div>
                #type#
            </td>
            <td width="100">
                <div class="valDesc">Required</div>
                #required#
            </td>
            <td>
                <div class="valDesc">Desc</div>
                #htmlFragment#
            </td>
        </tr>
    </table>
</div>
