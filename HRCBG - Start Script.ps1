Add-AzAccount

Enable-AzureRmAlias

Set-AzContext -SubscriptionName "YouforceOne Dev"
Set-AzContext -SubscriptionName "YouforceOne Perf"
Set-AzContext -SubscriptionName "YouforceOne Prod"

sl "C:\HRCB.ALM\Scripts"

$ResourceGroupName = "Yfo-Prod"
$ResourceGroupName = "Yfo-Acc"
$ResourceGroupName = "Yfo-Acc-Staging"
$ResourceGroupName = "YFO-Stark-dev"
$ResourceGroupName = "Yfo-Stark-Test"
$ResourceGroupName = "Yfo-Develop-Dev"
$ResourceGroupName = "Yfo-Develop-Test"
$ResourceGroupName = "Yfo-Main-Test"
$ResourceGroupName = "Yfo-Blackwood-Test"
$ResourceGroupName = "Yfo-Mormont-Test"


#---------------------Azure Devops function ---------------------#
sl "C:\DevOps\DevOps"
Import-Module .\AzureDevOps-Functions.psm1 -Force
$vstsAccount="youforceone"
$projectName="youforceone"
$PATToken="aidp5c2tyh65mjlxwh2drzqj3y5clzjq5hjdhfsq6mskck66hjqq"
Get-BuildAnalysis -buildDefinitionId 449 -PATToken $PATToken -minTime "2019-04-24" -maxTime "2019-05-06" -StepsTakenMoreThan 5 -ov p
#| Format-Table -AutoSize -Wrap -Expand | clip.exe

Get-UnusedTaskGroups -vstsAccount "youforceone" -projectName "youforceone" -PATToken $PATToken

Get-AzurePowershellVersionAnalysis -vstsAccount "youforceone" -projectName "youforceone" -PATToken $PATToken

Start-Build -vstsAccount "youforceone" -projectName "youforceone" -PATToken $PATToken -BuildDefinitionId 747 -SourceBranch "refs/heads/develop" -Parameters @{}

$AllTaskGroups = Get-TaskGroups -vstsAccount $vstsAccount -projectName $projectName -PATToken $PATToken | Sort-Object -Property $_.modifiedOn
#---------------------Azure Devops function ---------------------#



#---------------------HRCBG function ---------------------#
#Stop all web apps
.\Manage-WebApps.ps1 -ResourceGroupName $ResourceGroupName -Stop -Exclude $ResourceGroupName

#Stop all Continious web jobs
.\Stop-ContinuousWebJobs.ps1 -ResourceGroupName $ResourceGroupName

#Start all web apps
.\Manage-WebApps.ps1 -ResourceGroupName $ResourceGroupName -Start -Exclude $ResourceGroupName

#Start all Continious web jobs
.\Start-ContinuousWebJobs.ps1 -ResourceGroupName $ResourceGroupName
#---------------------HRCBG function ---------------------#

sl "C:\HRCB.ALM\Scripts\Utility"
Import-Module .\HRCBG-AzureAD.psm1 -Force
$ADAdminUserName = "vijay@blowlab.onmicrosoft.com"
$ADAdminPassword = "uglymoon11!"
$ApplicationName = "Check-conditions"
$ReplyURLs=@('https://myhr.raet.com')

.\Setup-HRCBGPingIntegration.ps1 -ADAdminUserName $ADAdminUserName -ADAdminPassword $ADAdminPassword -ADApplicationName $ApplicationName -ReplyURLs $ReplyURLs

<#$PropertiesToSet = @{
    'oauth2AllowIdTokenImplicitFlow' = $true
}

$HRCBGApplication = New-HRCBGAzureADApplication -Username $Username -Password $Password -DisplayName $ApplicationName -ReplyURLs $ReplyURLs -PropertiesToSet $PropertiesToSet#>