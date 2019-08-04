<cfset isChecked = getMetaKey('checked')>
<li>#(isChecked ? '&#10003; ' : '')# #htmlFragment#</li>
        