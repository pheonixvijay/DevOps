$testing = @{}
$response=@{};
$testing.Add("1","First One")
$testing.Add("2","Second One")
$testing.Add("3","Third One")
$testing.Add("4","Fourth One")

 foreach ($item in $testing.Keys)
 {
   $lineBreak = "$($item) took $($testing[$item])"
   $lineBreak+="`r`n"
   $lineBreak+="junk line"
   $response.Add($item,$lineBreak)
 }

$response |Format-Table -AutoSize -Wrap

$test = [datetime]::Parse("2019-04-08T10:20:43.9360269Z")

$date=Get-Date

$date.ToShortDateString()

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "","ogdkdoscf5ninzjcm65mqau55gnimjm2oalcezw5mm2xfoo4wzda")))
$authHeader = @{Authorization="Basic $base64AuthInfo"}
$AllBuilsLogs = Invoke-RestMethod -Uri "https://youforceone.visualstudio.com/youforceone/_apis/build/builds/65448/logs/2?api-version=5.0" -Method Get -ContentType "text/plain" -Headers $authHeader

$result = $AllBuilsLogs.Trim().Split("`r`n")

#Write-Host $result | Format-Table -AutoSize -Wrap

#Write-Host $result[0].Split("##")[2]
    $Response = @();
    
    if($result[0].Split("##")[2] -ne "[section]Starting: Job"){
      #write-output $result[0]
      $StartTIme = [datetime]::Parse($result[0].Split("##")[0].Trim())
      $EndTime = [datetime]::Parse($result[$($result.Length) - 1].Split("##")[0].Trim())

      $Response+="$($result[0].Split("##")[2])"
      $Response+=$EndTime - $StartTIme
    }


#-------------------------------------PSObject-----------------------------------------#
$CustomObject = New-Object -TypeName PSObject

$CustomObject | Add-Member -Type NoteProperty -Name "FirstVariable" -Value 1

$HashTable=@{}

$HashTable.Add(1,"value 1")
$HashTable.Add(2,"value 2")
$HashTable.Add(3,"value 3")

$CustomObject | Add-Member -Type NoteProperty -Name "SecondVariable" -Value $HashTable
$AnotherCustomObject = New-Object -TypeName PSObject
$AnotherCustomObject | Add-Member -Type NoteProperty -Name "AnotherVariable" -Value 1
$CustomObject | Add-Member -Type NoteProperty -Name "ArrayVariable" -Value @()
$CustomObject.ArrayVariable+=$AnotherCustomObject


$CustomObject.ArrayVariable[0]
#-------------------------------------PSObject-----------------------------------------#

foreach ($item in $p.BuildInfo)
{
  foreach ($steps in $item.StepsThatTakeTime)
  {
    $item
  }
  
}


Get-AzureRmResource -ResourceGroupName $ResourceGroupName -Name $ResourceGroupName | Set-AzureRmResource -Tag @{Name="CostCenter";Value="0001"}


  $table = New-Object System.Data.DataTable
  
$table.Columns.Add("TaskGroupId","string")| Out-Null
  $table.Columns.Add("TaskGroup","string")| Out-Null
  $table.Columns.Add("Owner","string")| Out-Null
  $table.Columns.Add("LastModifiedOn","string")| Out-Null
  $table.Columns.Add("URI","string")| Out-Null
  
  $r = $table.NewRow()
  
   $r.'TaskGroupId' = "65348023-059c-46d1-ae56-a3419fa61697"
      $r.'TaskGroup' = "RLS-HRCBG-TEMPORAL Stop AuthorizationWebJob"
      $r.'Owner' = "Aragón Olalla, Jose Mariano"
      $r.'LastModifiedOn' = "3/29/2019"
      $r.'URI' = "https://youforceone.visualstudio.com/youforceone/_taskgroup/65348023-059c-46d1-ae56-a3419fa61697"
  		
  $table.Rows.Add($r)
    $r = $table.NewRow()	
    
      $r.'TaskGroupId' = "65348023-059c-46d1-ae56-a3419fa61697"
      $r.'TaskGroup' = "RLS-HRCBG-TEMPORAL Stop AuthorizationWebJob"
      $r.'Owner' = "Aragón Olalla, Jose Mariano"
      $r.'LastModifiedOn' = "3/29/2019"
      $r.'URI' = "https://youforceone.visualstudio.com/youforceone/_taskgroup/65348023-059c-46d1-ae56-a3419fa61697"
  
  $table.Rows.Add($r)	
  
  $table | Sort-Object -Property $_.LastModifiedOn |  Export-Csv -Path "C:\Temp\UnusedTaskGroupAsOn$(get-date -f yyyy-MM-dd).csv" -NoTypeInformation
  

  $a = @{a=1;b=2;d=4;c=3}
  
  $a.GetEnumerator() | sort -Property name| Format-Table -auto -HideTableHeaders
  
  ($a.GetEnumerator()  | % { "{$($_.Name):$($_.Value)}" }) -join ','
  
  $Response = @();
  
  foreach ($item in $a.Keys)
  {
    $Response+= "\`"$($item)\`":\`"$($a[$item])\`""
  }
  
  write-host "{$($Response -join ',')}"
  
  #_-------------------------------------------------------------------------
  #JSON Object------------------------------

  $json = @"
{
  "queue": {
    "id": 33
  },
  "definition": {
    "id": 449
  },
  "project": {
    "id": "869509c5-990c-43b5-bfa1-b60d0dc15446"
  },
  "sourceBranch": "refs/heads/develop",
  "sourceVersion": "",
  "reason": 1,
  "demands": [
    "Agent.Name -equals Build01_Agent02"
  ],
  "parameters": "{\"ForceAnalysis\":\"false\",\"system.debug\":\"false\",\"Team\":\"Mormont\"}"
}
"@ 

$json = $json| ConvertFrom-Json
$json.queue.id=25
$json.queue.id

$json
  #JSON Object------------------------------

  $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
$Parameters['Name'] = ''
foreach($Child in @('Abe','Karen','Joe')) {
    $Parameters.Add('Children', $Child)
}

$Request = [System.UriBuilder]'http://www.example.com/somepage.php'

$Request.Query = $Parameters.ToString()

$ResourceGroupName = "Yfo-Mormont-Dev"
Remove-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ResourceGroupName -DatabaseName "yfo-mormont-dev-client2"
Remove-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ResourceGroupName -DatabaseName "yfo-mormont-dev-client3"

 Get-AzureADApplication | ForEach-Object {Remove-AzureADApplication -ObjectId $_.ObjectId}
 
$resourceAccess = @(@{'resourceAccess' = @(@{
                'id'   = '311a71cc-e848-46a1-bdf8-97ff7156d8e6'
                'type' = 'Scope'
            })
        'resourceAppId'                = '00000002-0000-0000-c000-000000000000'
    })

$PropertiesToSet = @{
    'oauth2AllowIdTokenImplicitFlow' = $true
    'requiredResourceAccess'         = $resourceAccess
}
$PropertiesToSet | ConvertTo-Json -Depth 100 -OutVariable test
$test

Get-AzureADServicePrincipal -Filter "DisplayName eq 'Microsoft Graph' or DisplayName eq 'Windows Azure Active Directory'" -OutVariable result
Get-AzureADServicePrincipal -SearchString "Windows Azure Active Directory"

Get-AzureADServicePrincipal -Filter "DisplayName eq 'Microsoft Graph' or DisplayName eq 'Windows Azure Active Directory'" -OutVariable AzureADServicePrincipals

Get-AzureADServicePrincipal -Filter "DisplayName eq 'Microsoft Graph' or DisplayName eq 'Windows Azure Active Directory'" -OutVariable AzureADServicePrincipals | Select-Object  ObjectId, AppId, DisplayName

$resourceAccess = @(@{'resourceAccess' = @(@{
                'id'   = ($AzureADServicePrincipals[0].Oauth2Permissions | Where-Object { $_.Value -eq 'User.Read' }).Id
                'type' = 'Scope'
            })
        'resourceAppId'                = $AzureADServicePrincipals[0].AppId
    }, @{'resourceAccess' = @(@{
                'id'   = ($AzureADServicePrincipals[1].Oauth2Permissions | Where-Object { $_.Value -eq 'User.Read' }).Id
                'type' = 'Scope'
            })
        'resourceAppId'   = $AzureADServicePrincipals[1].AppId
    })

$PropertiesToSet = @{
    'oauth2AllowIdTokenImplicitFlow' = $true
    'requiredResourceAccess'         = $resourceAccess
}


$UpdatedApplicationManifest = Set-AzureADApplicationViaManifest -OauthToken (Get-UserImpersonationToken -ADAdminUserName $ADAdminUserName -ADAdminPassword $ADAdminPassword) -PropertiesToSet $PropertiesToSet -ObjectId $NewApplication.ObjectId -AppId $NewApplication.AppId

$ConnectionString='server=tcp:yfo-develop-dev.database.windows.net,1433;Database=YFO-Develop-Dev-Client1;User ID=client1;Password=0u3$dGT!AK$$7k;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;MultipleActiveResultSets=True;Persist security Info=true;'
  $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($ConnectionString)

function OpenSqlConnectionNew ([ref]$Connection){
  $Timeout = 60
  $RetryInterval = 5
  $Timer = [Diagnostics.Stopwatch]::StartNew()
  while($connection.State -ne 'Open' -and $Timer.Elapsed.TotalSeconds -lt $Timeout){
    try{
      $Connection.Open()
    }Catch{
      Write-Output -InputObject "Error openning connection $($connection.State). Retry connection..."
      Write-Output -InputObject "Exception message - $_"
      Start-Sleep -Seconds $RetryInterval
    }
  }
  $error.clear()
}

		
function OpenSqlConnection ($Connection){
  $Timeout = 10
  $RetryInterval = 5
  $Connected = $false
  $Timer = [Diagnostics.Stopwatch]::StartNew()

  while(!$Connected -and ($Timer.Elapsed.TotalSeconds -lt $Timeout)){
    try{
      $Connection.Open()
      $Connected = $true
    }Catch{
      Write-Output -InputObject "Error openning connection $connection"
      Write-Output -InputObject $Error[0]
      Start-Sleep -Seconds $RetryInterval
    }
  }
  $error.clear()
}

try
{
  OpenSqlConnection($connection)
  $connection.State

}
catch
{
    Switch($_.Exception.InnerException.Class){
      16 {Write-Output -InputObject $Error[0].Exception.InnerException.Message}
      Default {Write-Output -InputObject ($Error[0].Exception)}
    }
    }
    
function Get-Something
{
  param(
    [switch]$TestSwitch
  )
  
  if($TestSwitch){
    Write-Host "true"
  }
}

$Params=@{

  TestSwitch=$true
}

#Get-Something -TestSwitch:$false
Get-Something @Params


$testString = 'asdsahdjsa_[<>*%&:\\?+/]())()()__$______'
$testString=$testString -replace '[<>*%&:\\?+/]' 
$testString 


$SqlAdministratorLoginPassword = ConvertTo-SecureString -String "youforce1!" -AsPlainText -Force
$ResourceGroupName='YFO-FairyTail'

if(!(Get-AzResourceGroup -Name $ResourceGroupName -Location 'WestEurope')){

  New-AzResourceGroup -Name $ResourceGroupName -Location 'WestEurope' -Force
}
$param=@{

Name="TestDeployment-8"
TemplateFile = '..\Templates\Common\YFO.Azure.Common.json' 
TemplateParameterFile ='..\Templates\Common\YFO.Azure.Common.Parameters.Dev.json'
Prefix =$ResourceGroupName
ResourceGroupName=$ResourceGroupName
SqlAdministratorLogin ='rootuser' 
SqlAdministratorLoginPassword =$SqlAdministratorLoginPassword 
Mode= 'Incremental' 
'RedisCache.SKU.Name' ='Basic' 
'RedisCache.SKU.Capacity'= 1
DeploymentDebugLogLevel ='All'
}

New-AzResourceGroupDeployment @param