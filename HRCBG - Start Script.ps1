Add-AzAccount

Enable-AzureRmAlias

Set-AzContext -SubscriptionName "YouforceOne Dev"
Set-AzContext -SubscriptionName "YouforceOne Perf"
Set-AzContext -SubscriptionName "YouforceOne Prod"

sl "C:\HRCB.ALM\Scripts"

$ResourceGroupName = "Yfo-Prod"
$ResourceGroupName = "Yfo-Acc"
$ResourceGroupName = "Yfo-Acc-Staging"
$ResourceGroupName = "Yfo-Stark-Dev"
$ResourceGroupName = "Yfo-Stark-Test"
$ResourceGroupName = "Yfo-Develop-Dev"
$ResourceGroupName = "Yfo-Develop-Test"
$ResourceGroupName = "Yfo-Main-Test"
$ResourceGroupName = "Yfo-Blackwood-Test"


#---------------------VSTS function ---------------------#
. C:\Azure\VSTS-Functions.ps1
Get-BuildAnalysis -buildDefinitionId 449 -PATToken "" -minTime "2019-04-24" -maxTime "2019-05-06" -StepsTakenMoreThan 5 -ov p
#| Format-Table -AutoSize -Wrap -Expand | clip.exe

Get-UnusedTaskGroups -vstsAccount "youforceone" -projectName "youforceone" -PATToken ""
#---------------------VSTS function ---------------------#



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