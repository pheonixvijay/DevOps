function Grant-OAuth2PermissionsToApp{
    Param(
        [Parameter(Mandatory=$true)]$Username, #global administrator username
        [Parameter(Mandatory=$true)]$Password, #global administrator password
        [Parameter(Mandatory=$true)]$azureAppId #application ID of the azure application you wish to admin-consent to
    )

    $Username="vijay@blowlab.onmicrosoft.com"
    $Password="uglymoon11!"
    

    $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)
    $res = login-azurermaccount -Credential $mycreds

    $context = Get-AzureRmContext
    $tenantId = $context.Tenant.Id
    
    $refreshToken = @($context.TokenCache.ReadItems() | Where-Object {$_.tenantId -eq $tenantId})[0].AccessToken
    $body = "grant_type=refresh_token&refresh_token=$($refreshToken)&resource=74658136-14ec-4630-ad9b-26e160ff0fc6"
    $apiToken = Invoke-RestMethod "https://login.windows.net/$tenantId/oauth2/token" -Method POST -Body $body -ContentType 'application/x-www-form-urlencoded'
    
    
    
    $header = @{
    'Authorization' = 'Bearer ' + $apiToken.access_token
    'X-Requested-With'= 'XMLHttpRequest'
    'x-ms-client-request-id'= [guid]::NewGuid()
    'x-ms-correlation-id' = [guid]::NewGuid()}
    $url = "https://main.iam.ad.ext.azure.com/api/RegisteredApplications/$azureAppId/Consent?onBehalfOfAll=true"
    Invoke-RestMethod –Uri $url –Headers $header –Method POST -ErrorAction Stop
}
Grant-OAuth2PermissionsToApp -Username "vijay@blowlab.onmicrosoft.com" -Password "uglymoon11!" -azureAppId "b83b7a78-8dbf-49d5-8808-0138143f8a35" 
