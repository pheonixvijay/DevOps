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
    return $Response



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
  

  $a = @{a=1;b=2;c=3;d=4}
  
  $a.GetEnumerator() | sort -Property name
  