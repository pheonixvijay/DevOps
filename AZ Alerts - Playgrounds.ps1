$ResourceGroupName='yfo-mormont-dev'
$ResourceName='yfo-mormont-dev' 
$ResourceType='*' #Requried
$MetricName ='CPUPercentage' #validate and reply back with the selected metric available or not
$PrimaryAggregationType = $true
$Operator='GreaterThan' # add validations on this
$MetricThreshold=87 # cannot be greater than 100
$ReceiverType='Email' # Validation set on type
$Receiver=@{
  Name='Inform Vijay'
  ReceiverLocation='v.inbaaraaj@devon.nl'
}
$GroupName =''
# keep it to seconds and default it certain period (5)
$WindowSize = New-TimeSpan -Minutes 5 # Period
$Frequency = New-TimeSpan -Minutes 1 # Frequency of evaluation
#$Alerts = Get-AzMetricAlertRuleV2 -ResourceGroupName "yfo-mormont-dev"
$Severiety=2

Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $ResourceGroupName -OutVariable AppServicePlan

Get-AzMetricDefinition -ResourceId $AppServicePlan.Id -OutVariable MetricDefinition

$SelectedMetric = $MetricDefinition|Where-Object {$_.Name.Value -like $MetricName}

<#

    Here's the logic for the code to check the mertric definition with the input given
    In case don't match see if we can output warning and then do a wild card search on the input

#>
New-AzMetricAlertRuleV2Criteria -MetricName $SelectedMetric.Name.Value -TimeAggregation $SelectedMetric.PrimaryAggregationType -Operator $Operator -Threshold $MetricThreshold -OutVariable NewCriteria

New-AzActionGroupReceiver -Name "Inform DM via email" -EmailReceiver -EmailAddress "v.inbaaraaj@devon.nl" -OutVariable NewReceiver1

New-AzActionGroupReceiver -Name "Inform DM via sms" -SmsReceiver -CountryCode '91' -PhoneNumber '9036261502' -OutVariable NewReceiver2

$Receivers = New-Object System.Collections.Generic.List[Microsoft.Azure.Commands.Insights.OutputClasses.PSActionGroupReceiverBase]

$Receivers+=$NewReceiver1
$Receivers+=$NewReceiver2

Set-AzActionGroup -ResourceGroupName $ResourceGroupName -Name 'Notify DM' -ShortName 'NotifyDM' -Receiver $Receivers -OutVariable ActionGroup

$Test = New-AzActionGroup -ActionGroupId $ActionGroup.Id


#Get-AzActionGroup -ResourceGroupName $ResourceGroupName -Name $ActionGroup.Name


Add-AzMetricAlertRuleV2 -Name 'Alert on CPU percentage' -ResourceGroupName $ResourceGroupName -Condition $NewCriteria -ActionGroup $Test -TargetResourceScope $AppServicePlan.Id -WindowSize $WindowSize -Frequency $Frequency -TargetResourceType 'AppServicePlan' -TargetResourceRegion 'WestEurope' -Severity 2

sl "C:\HRCB.ALM\Scripts\Monitoring"
$Params=@{
  ResourceGroupName='yfo-mormont-test'
  ResourceName='yfo-mormont-test'
  ResourceType='Microsoft.Web/serverfarms'
  
  SignalName='CpuPercentage'
  Operator='GreaterThan'
  MetricThreshold=77
  
  #AlertRuleName='werwerwerwrete34wqeqwe<>*%&:\?+/'
  #ConditionModificationType='Modify'
  
  ReceiverType='Email'
  ReceiverValue='v.inbaaraaj@devon.nl'
  
  #ReceiverModificationType='Modify'
  
  AggregationGranularity=900
  EvaluationFrequency=900
  
  ReadOnly=$false
  #DisableAlertRule=$true
}

.\Manage-AzAlert.ps1 @Params

$AvailableMetricAlerts = Get-AzMetricAlertRuleV2 -ResourceGroupName 'Yfo-Mormont-Test' -WarningAction Ignore | Where-Object { $_.Scopes[0] -eq '/subscriptions/98dfd798-c63c-4118-b700-f03c1338da88/resourceGroups/YFO-Mormont-Test/providers/Microsoft.Web/serverfarms/YFO-Mormont-Test' }

$Results = @{}
$Results.Name=$AvailableMetricAlerts.Name
$Results.ResourceGroup=$AvailableMetricAlerts.ResourceGroup
$Results.ResourceName = (Get-AzResource -ResourceId $AvailableMetricAlerts.Scopes).Name
$Results.ResourceType = $AvailableMetricAlerts.TargetResourceType
$Results.WindowSize=$AvailableMetricAlerts.WindowSize
$Results.EvaluationFrequency=$AvailableMetricAlerts.EvaluationFrequency
$Results | FT -auto -HideTableHeaders

$Actions = @()
foreach ($item in $AvailableMetricAlerts.Actions)
{
  $ActionInfo = Get-AzActionGroup | Where-Object {$_.Id -eq $item.ActionId}
  $Actions += [PSCustomObject] @{
    Name = $ActionInfo.Name
    Email=''
  
  }


}
$Actions | FT -auto -HideTableHeaders


try
{
  
  Get-AzMetricAlertRuleV2 -ResourceGroupName 'yfo-mormont-test' -Name "asdasas" -WarningAction Ignore -OutVariable Test -ErrorAction Continue

}
catch
{
  "Error was $_"
  $line = $_.InvocationInfo.ScriptLineNumber
  "Error was in Line $line"
}

$ResourceName='yfo-mormont-test'
$ResourceType='*'
$ResourceGroupName='yfo-mormont-test'
$SelectedResource = Get-AzResource -Name $ResourceName -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ErrorAction SilentlyContinue -ErrorVariable CheckResourceExist
If ($CheckResourceExist -or $SelectedResource.Count -eq 0) {
  Exit "No resource found in Resource Group - $ResourceGroupName with Resource Name - $ResourceName and Resource Type - $ResourceType. `r`n Please refine your criteria to set the alerts"
}

$ResourceGroupName='yfo-mormont-test'
$MetricAlertRuleV2Name='Alert on yfo-mormont-test for exceptionscount'
$Alert = Get-AzMetricAlertRuleV2 -ResourceGroupName $ResourceGroupName -Name $MetricAlertRuleV2Name -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -ErrorVariable CheckRuleExists
$Alert.Criteria


$AvailableMetricAlerts = Get-AzMetricAlertRuleV2 -ResourceGroupName $ResourceGroupName -WarningAction Ignore