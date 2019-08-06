$url = "https://youforceone.vsrm.visualstudio.com/869509c5-990c-43b5-bfa1-b60d0dc15446/_apis/release/releases/33056?api-version=5.0"

Write-Host "URL: $url"
$originalRelease = (Invoke-RestMethod -Uri $url -Headers $(Get-AuthorizationHeader -PATToken "okqzxs2qrnpmpa5qobkjvmtyqano5sde6xbyuak5vtzwml2grywa") -Method Get -ContentType "application/json")

write-host "originalRelease: $originalRelease"

#$originalRelease = ConvertFrom-Json -InputObject $originalRelease

# Update release variables and name  
$RamdonName=''
$RamdonName = (((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_}) -join '')
$originalRelease.variables.TenantName.value = 'sandbox-'+$RamdonName
$originalRelease.variables.TenantId.value = new-guid
#$originalRelease.Name = $newName

####****************** update the modified object **************************
$updatedRelease = @($originalRelease) | ConvertTo-Json -Depth 100
$updatedRelease = [Text.Encoding]::UTF8.GetBytes($updatedRelease)

$updatedef = Invoke-RestMethod -Uri $url -Method Put -Body $updatedRelease -ContentType "application/json" -Headers $(Get-AuthorizationHeader -PATToken "okqzxs2qrnpmpa5qobkjvmtyqano5sde6xbyuak5vtzwml2grywa")

Write-host "==========================================================" 
Write-host "The value of Variable 'TenantName' is updated to" $updatedef.variables.TenantName.value
Write-host "The value of Variable 'TenantId' is updated to" $updatedef.variables.TenantId.value
Write-host "=========================================================="


function Get-AuthorizationHeader{

  param
  (
    [String]
    [Parameter(Mandatory)]
    $PATToken
  )

  $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$PATToken)))
  $authHeader = @{Authorization="Basic $base64AuthInfo"}
  
  
  return $authHeader
}