<cfset httpCode = getMetaKey('httpCode')>
            
<div class="api-method-response-example">
    <div class="status-code-#httpCode#">
        <span class="status-bullet"></span>
        #httpCode#
    </div>
    <div>#htmlFragment#</div>
</div>