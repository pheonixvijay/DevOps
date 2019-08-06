function Get-UserImpersonationToken {
    <#
      .SYNOPSIS
      Describe purpose of "Get-UserImpersonationToken" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER Username
      Describe parameter -Username.

      .PARAMETER Password
      Describe parameter -Password.

      .EXAMPLE
      Get-UserImpersonationToken -Username Value -Password Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Get-UserImpersonationToken

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


    Param(
        [Parameter(Mandatory, HelpMessage = 'Global administrator username')]$Username,
        [Parameter(Mandatory, HelpMessage = 'Global administrator password')]$Password
    )

    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $AdminCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($Username, $SecurePassword)
    $LoginResponse = Connect-AzureAD -Credential $AdminCredentials

    $FormFields = @{'resource' = '74658136-14ec-4630-ad9b-26e160ff0fc6' #Guid for Auidance https://management.core.windows.net
        'client_id'            = '1950a258-227b-4e31-a9cf-717495945fc2' #Client ID for Azure PowerShell 
        'grant_type'           = 'password'
        'username'             = $Username
        'password'             = $Password
    }

    try {
        $OauthResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$($LoginResponse.TenantId)/oauth2/token" -ContentType 'application/x-www-form-urlencoded' -Body $FormFields 
    }
    catch {
        Write-Verbose -Message "Something went wrong in requesting User Impersonation Token. Exception message $($_.Exception.Message)"
    }

    return $OauthResponse.access_token
}

function Grant-ConsetToApplication {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'Global administrator username')]$Username,
        [Parameter(Mandatory, HelpMessage = 'Global administrator password')]$Password,
        [Parameter(Mandatory, HelpMessage = 'Application Id for which Admin Consent to be provided')]$ApplicationId
    )

    $OauthToken = Get-UserImpersonationToken -Username $Username -Password $Password
    
    $Headers = @{
        'Authorization'   = "Bearer $OauthToken"
        'x-ms-path-query' = '/api/AADGraph/myorganization/consentToApp?api-version=2.0'
        'Content-Type'    = 'application/json'
    }

    $Body = @{
        clientAppId   = $ApplicationId
        onBehalfOfAll = $true
        checkOnly     = $false
        tags          = @()
    }

    try {
        Invoke-RestMethod -Method Post -Uri 'https://main.iam.ad.ext.azure.com/api/AADGraph' -Headers $Headers -Body $Body

        Write-Verbose "Successfully granted Admin consent for application ID $($ApplicationId)"
    }
    catch {
        Write-Verbose -Message "Something went wrong in requesting User Impersonation Token. Exception message $($_.Exception.Message)"
    }

}

