function Invoke-AzureDevopsApi {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'Uri')][uri]$Uri,
        [Parameter(Mandatory = $true, HelpMessage = 'Project name as string')][Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [Parameter(Mandatory = $true, HelpMessage = 'Content Type')][string]$ContentType,
        [Parameter(Mandatory = $true, HelpMessage = 'Headers')][Collections.IDictionary]$Headers,
        [Parameter(Mandatory = $false, HelpMessage = 'Body')][Object]$Body) 

    $response = Invoke-RestMethod -Uri $Uri -Method $Method -ContentType $ContentType -Headers $Headers -Body $Body
    
    return $response
}

function Get-LogInfo {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(HelpMessage = 'Build Id')][string]$BuildId = "65486",
        [Parameter(Mandatory = $true, HelpMessage = 'YFO-Develop build definition id string')][string]$LogId,
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken
    )
    		
    
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))

    $authHeader = @{Authorization = "Basic $base64AuthInfo" }

    $AllBuilsLogs = Invoke-RestMethod -Uri "https://$($vstsAccount).visualstudio.com/$($projectName)/_apis/build/builds/$($BuildId)/logs/$($LogId)?api-version=5.0" -Method Get -ContentType "text/plain" -Headers $authHeader
  
    $result = $AllBuilsLogs.Trim().Split("`r`n")
       
    $Response = @();
    
    if ($result[0].Split("##")[2] -ne "[section]Starting: Job") {
        #write-output $result[0]
        $StartTIme = [datetime]::Parse($result[0].Split("##")[0].Trim())
        $EndTime = [datetime]::Parse($result[$($result.Length) - 1].Split("##")[0].Trim())

        $Response += "$($LogId)-$($result[0].Split("##")[2])"
        $Response += $EndTime - $StartTIme
    }
    return $Response
  
}

function Get-EachBuildStepInfo {
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(HelpMessage = 'Build Id')][string]$BuildId = "65486",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))

    $authHeader = @{Authorization = "Basic $base64AuthInfo" }

    $AllBuilsLogs = Invoke-RestMethod -Uri "https://$($vstsAccount).visualstudio.com/$($projectName)/_apis/build/builds/$($BuildId)/logs?api-version=5.0" -Method Get -ContentType "application/json" -Headers $authHeader | Sort-Object -Property $_.id
  
    $AllStepInfo = @{ }
  
    foreach ($item in $AllBuilsLogs.value) {
  
        if ($item.lineCount -ge 3) {
  
            $LogsInfo = Get-LogInfo -vstsAccount "YouforceOne" -projectName "YouforceOne" -BuildId $BuildId -LogId $item.id -PATToken $PATToken
      
            if ($LogsInfo -ne $null) {
                #Write-Output $LogsInfo[0]
                $AllStepInfo.Add($LogsInfo[0], [math]::Round($LogsInfo[1].TotalMinutes, 2))
            }
        }
    }
    return $AllStepInfo
}

function Get-BuildAnalysis {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'Build definition id')][string]$buildDefinitionId,
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [Parameter(HelpMessage = 'Min date in YYYY-MM-DD')][string]$minTime = "2019-04-03",
        [Parameter(HelpMessage = 'Max date in YYYY-MM-DD')][string]$maxTime = "2019-04-08",
        [Parameter(HelpMessage = 'Filter steps taken more than x minutes')][int]$StepsTakenMoreThan = 5
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))

    $authHeader = @{Authorization = "Basic $base64AuthInfo" }

    $AllBuildsInfo = Invoke-RestMethod -Uri "https://$($vstsAccount).visualstudio.com/$($projectName)/_apis/build/builds?definitions=$($buildDefinitionId)&api-version=5.0&minTime=$($minTime)&maxTime=$($maxTime)" -Method Get -ContentType "application/json" -Headers $authHeader

    $response = New-Object -TypeName PSObject
    $response | Add-Member -Type NoteProperty -Name "BuildInfo" -Value @()

    foreach ($res in $AllBuildsInfo.value) {
        $BuildInfo = New-Object -TypeName PSObject
        $BuildInfo | Add-Member -Type NoteProperty -Name "BuildId" -Value ""
        $BuildInfo | Add-Member -Type NoteProperty -Name "TotalTime" -Value 0.00
        $BuildInfo | Add-Member -Type NoteProperty -Name "StepsThatTakeTime" -Value @()
        if ($res.result -eq "succeeded") {
            try {
                $TotalTimeTakenByBuild = ([datetime]::Parse($res.finishTime) - [datetime]::Parse($res.startTime))
        
                $AllStepInfo = Get-EachBuildStepInfo -vstsAccount $vstsAccount -projectName $projectName -BuildId $res.id -PATToken $PATToken
                foreach ($key in $AllStepInfo.Keys) {
                    if ($AllStepInfo[$key] -ge $StepsTakenMoreThan) {
                        $StepsThatTakeTime = New-Object -TypeName PSObject
                        $StepsThatTakeTime | Add-Member -Type NoteProperty -Name "Description" -Value ""
                        $StepsThatTakeTime | Add-Member -Type NoteProperty -Name "TimeTaken" -Value 0.00
                        $StepsThatTakeTime.Description = $key
                        $StepsThatTakeTime.TimeTaken = $AllStepInfo[$key]
                        $BuildInfo.StepsThatTakeTime += $StepsThatTakeTime
                    }
                }
        
                $BuildInfo.BuildId = $res.id
                $BuildInfo.TotalTime = [math]::Round($TotalTimeTakenByBuild.TotalMinutes, 1)
                $response.BuildInfo += $BuildInfo
            }
            catch {
                "Error was $_"
                $line = $_.InvocationInfo.ScriptLineNumber
                "Error was in Line $line"
            }
        }
    }

    return $response.BuildInfo
}

function Get-TaskGroups {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [switch]$GroupByVersions)
    

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))

    $authHeader = @{Authorization = "Basic $base64AuthInfo" }

    $AllTaskGroups = Invoke-RestMethod -Uri "https://$($vstsAccount).visualstudio.com/$($projectName)/_apis/distributedtask/taskgroups/?api-version=5.0-preview.1" -Method Get -ContentType "application/json" -Headers $authHeader
  
    if ($GroupByVersions) {
        $customObj = $AllTaskGroups | ConvertTo-Json -Depth 100 | ConvertFrom-Json

        $Response = @{
            TaskGroupsWithVersion = @(@{
                    id       = ''
                    Versions = @()
                })
        }

        foreach ($item in $customObj.value) {
            if ($Response.TaskGroupsWithVersion | Where-Object { $_.id -eq $item.id }) {
                $Response.TaskGroupsWithVersion | Where-Object { $_.id -eq $item.id } | ForEach-Object { $_.Versions += $item }
            }
            else {
                $Response.TaskGroupsWithVersion += @{'id' = $item.id
                    'Versions'                            = @($item)
                }
            }
        }
        return $Response
    }
    else {
        return $AllTaskGroups
    }
}

function Get-TaskGroup {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [Parameter(Mandatory = $true, HelpMessage = 'Task Group ID as string')][string]$TaskGroupId)
    

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))

    $authHeader = @{Authorization = "Basic $base64AuthInfo" }

    $AllTaskGroups = Invoke-RestMethod -Uri "https://dev.azure.com/$($vstsAccount)/$($projectName)/_apis/distributedtask/taskgroups/$($TaskGroupId)" -Method Get -ContentType "application/json" -Headers $authHeader
  
    return $AllTaskGroups
}

function Get-BuildDefinitions {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [Parameter(HelpMessage = 'If specified, filters to definitions whose names match this pattern.')][string]$Name,
        [Parameter(HelpMessage = 'A comma-delimited list that specifies the IDs of definitions to retrieve.')][string]$DefinitionIds
    )
  
    $authHeader = Get-AuthorizationHeader -PATToken $PATToken
  
    $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    $Parameters['name'] = $Name
    $Parameters['definitionIds'] = $DefinitionIds
  
    $Request = [System.UriBuilder]"https://dev.azure.com/$($vstsAccount)/$($projectName)/_apis/build/definitions"

    $Request.Query = $Parameters.ToString()
  
    return Invoke-RestMethod -Uri $Request.Uri -Method Get -ContentType "application/json" -Headers $authHeader
}

function Get-ProjectDetails {
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName,
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken)
  
    $authHeader = Get-AuthorizationHeader -PATToken $PATToken
  
    $Response = Invoke-RestMethod -Uri "https://dev.azure.com/$($vstsAccount)/_apis/projects?api-version=5.0" -Method Get -ContentType "application/json" -Headers $authHeader
  
    return $Response.value | Where-Object { $_.name -eq $projectName }
}

function Get-AuthorizationHeader {

    param
    (
        [String]
        [Parameter(Mandatory)]
        $PATToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))
    $authHeader = @{Authorization = "Basic $base64AuthInfo" }
  
    return $authHeader
}

function Get-BuildsDependentOnTargetGroup {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [Parameter(Mandatory = $true, HelpMessage = 'Task Group ID as string')][string]$TaskGroupId
    )
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))

    $authHeader = @{Authorization = "Basic $base64AuthInfo" }

    $AllBuildsUsingTaskGroup = Invoke-RestMethod -Uri "https://$($vstsAccount).visualstudio.com/$($projectName)/_apis/build/Definitions?taskIdFilter=$($TaskGroupId)" -Method Get -ContentType "application/json" -Headers $authHeader
  
    return $AllBuildsUsingTaskGroup

}

function Get-ReleasesDependentOnTargetGroup {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [Parameter(Mandatory = $true, HelpMessage = 'Task Group ID as string')][string]$TaskGroupId
    )
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))

    $authHeader = @{Authorization = "Basic $base64AuthInfo" }

    $AllReleasesUsingTaskGroup = Invoke-RestMethod -Uri "https://$($vstsAccount).vsrm.visualstudio.com/$($projectName)/_apis/Release/definitionEnvironments?taskGroupId=$($TaskGroupId)" -Method Get -ContentType "application/json" -Headers $authHeader
  
    return $AllReleasesUsingTaskGroup

}

function Get-TaskGroupsDependentOnTargetGroup {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [Parameter(Mandatory = $true, HelpMessage = 'Task Group ID as string')][string]$TaskGroupId
    )
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))

    $authHeader = @{Authorization = "Basic $base64AuthInfo" }

    $AllTaskGroupsUsingTaskGroup = Invoke-RestMethod -Uri "https://$($vstsAccount).visualstudio.com/$($projectName)/_apis/distributedtask/taskgroups?expanded=false&taskIdFilter=$($TaskGroupId)" -Method Get -ContentType "application/json" -Headers $authHeader
  
    return $AllTaskGroupsUsingTaskGroup

}

function Get-UnusedTaskGroups {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken)
    
  
    $AllTaskGroups = Get-TaskGroups -vstsAccount $vstsAccount -projectName $projectName -PATToken $PATToken | Sort-Object -Property $_.modifiedOn

    $table = New-Object System.Data.DataTable 
  
    $table.Columns.Add("TaskGroupId", "string") | Out-Null
    $table.Columns.Add("TaskGroup", "string") | Out-Null
    $table.Columns.Add("Owner", "string") | Out-Null
    $table.Columns.Add("LastModifiedOn", "string") | Out-Null
    $table.Columns.Add("URI", "string") | Out-Null
  
    foreach ($TaskGroup in $AllTaskGroups.value) {
        $r = $table.NewRow()
    
        $Dependentbuilds = Get-BuildsDependentOnTargetGroup -vstsAccount $vstsAccount -projectName $projectName -PATToken $PATToken -TaskGroupId $TaskGroup.id
        $DependentReleases = Get-ReleasesDependentOnTargetGroup -vstsAccount $vstsAccount -projectName $projectName -PATToken $PATToken -TaskGroupId $TaskGroup.id
        $DependentTaskGroup = TaskGroupsDependentOnTargetGroup -vstsAccount $vstsAccount -projectName $projectName -PATToken $PATToken -TaskGroupId $TaskGroup.id
    
        if ($Dependentbuilds.count -eq 0 -and $DependentReleases.count -eq 0 -and $DependentTaskGroup.count -eq 0) {
    
            $r.'TaskGroupId' = $TaskGroup.id
            $r.'TaskGroup' = $TaskGroup.name
            $r.'Owner' = $TaskGroup.modifiedBy.displayName
            $r.'LastModifiedOn' = [datetime]::Parse($TaskGroup.modifiedOn).ToShortDateString()
            $r.'URI' = "https://$($vstsAccount).visualstudio.com/$($projectName)/_taskgroup/$($TaskGroup.id)"
            $table.Rows.Add($r)
        }
    }
  
    $path = "C:\DevOps\DevOps"
    if (!(test-path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }  
    $table | Sort-Object -Property $_.LastModifiedOn | Export-Csv -Path "C:\DevOps\DevOps\UnusedTaskGroupAsOn$(Get-date -f yyyyMMdd).csv" -NoTypeInformation
}

function Get-AzurePowershellVersionAnalysis {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [switch]$PrintToFile)
  
    $AllTaskGroups = Get-TaskGroups -vstsAccount $vstsAccount -projectName $projectName -PATToken $PATToken | Sort-Object -Property $_.modifiedOn

    $table = New-Object System.Data.DataTable 
  
    $table.Columns.Add("TaskGroupId", "string") | Out-Null
    $table.Columns.Add("TaskGroup", "string") | Out-Null
    $table.Columns.Add("TaskDisplayName", "string") | Out-Null
    $table.Columns.Add("PsVersion", "string") | Out-Null
  
    $UniqueTaskGroupId = $AllTaskGroups.value | Sort-Object id -Descending -Unique | Select-Object id

    foreach ($TaskGroupId in $UniqueTaskGroupId) {
        $TaskGroupWithVersions = Get-TaskGroup -vstsAccount $vstsAccount -projectName $projectName -PATToken $PATToken -TaskGroupId $TaskGroupId.id
        #if($TaskGroupId.id -eq '5e02a281-14a2-4ba6-b5a2-96b595c419e6'){
        $HighestVersion = ($TaskGroupWithVersions.value | Measure-Object -Property revision -Maximum).Maximum
        $VersionToAnalyze = $TaskGroupWithVersions.value | Where-Object { $_.revision -eq $HighestVersion }
        foreach ($item in $VersionToAnalyze.tasks) {
            if ($item.task.id -eq "72a1931b-effb-4d2e-8fd8-f8472a07cb62") {
                $r = $table.NewRow()
                $r.'TaskGroupId' = $VersionToAnalyze.id
                $r.'TaskGroup' = $VersionToAnalyze.name
                $r.'TaskDisplayName' = $item.displayName
                $r.'PsVersion' = $item.task.versionSpec
                $table.Rows.Add($r)   
            }
        }
        #}
    }
  
    $path = "C:\DevOps\DevOps"
    if (!(test-path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }
    if ($PrintToFile) {
        $table | Sort-Object -Property $_.LastModifiedOn | Export-Csv -Path "C:\DevOps\DevOps\AzurePowershellVersionAnalysisOn$(Get-date -f yyyyMMdd).csv" -NoTypeInformation
    }
    else { $table }
}

function ConvertTo-NewPowerShellVersionTask {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken,
        [string]$NewVersion = '4.*')

    
    $AllTaskGroups = Get-TaskGroups -vstsAccount "youforceone" -projectName "youforceone" -PATToken $PATToken -GroupByVersions
        
    foreach ($TaskGroup in $AllTaskGroups.TaskGroupsWithVersion) {
        $HighestVersion = ($TaskGroup.Versions | Measure-Object -Property revision -Maximum).Maximum
        $VersionToAnalyze = $TaskGroup.Versions | Where-Object { $_.revision -eq $HighestVersion }
        $UpdateTG = $false
        #if ($TaskGroup.id -eq '511be398-f63b-4548-a6a2-653aa494c9ab') {
        foreach ($task in $VersionToAnalyze.tasks) {
            if ($task.task.id -eq '72a1931b-effb-4d2e-8fd8-f8472a07cb62' -and $task.task.versionSpec ) {
                $task.task.versionSpec = $NewVersion
                $UpdateTG = $true
            }
        }
        if ($UpdateTG) {
            $VersionToAnalyze.comment = "Updated by Automated PowerShell script. Changed the Azure PowerShell task(s) version to $NewVersion"
            $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $PATToken)))
            $authHeader = @{Authorization = "Basic $base64AuthInfo" }

            Write-Host "Updating TG - $($VersionToAnalyze.name)"
            Invoke-RestMethod -Uri "https://dev.azure.com/$vstsAccount/$($projectName)/_apis/distributedtask/taskgroups/$($TaskGroup.id)?api-version=5.0-preview.1" -Method Put -ContentType "application/json" -Headers $authHeader -Body ($VersionToAnalyze | ConvertTo-Json -Depth 100)
        }        
        #}
    }
}

function Start-Build { 
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'VSTS account name as string')][string]$vstsAccount = "YouforceOne",
        [Parameter(HelpMessage = 'Project name as string')][string]$projectName = "YouforceOne",
        [Parameter(Mandatory = $true, HelpMessage = 'Build definition Id')][int]$BuildDefinitionId,
        [Parameter(Mandatory = $true, HelpMessage = 'Source Branch')][string]$SourceBranch,
        [Parameter(HelpMessage = 'Parameters')][hashtable]$Parameters,
        [Parameter(Mandatory = $true, HelpMessage = 'PAT Token')][string]$PATToken)
    
    $Header = Get-AuthorizationHeader -PATToken $PATToken
    $Header += @{"Accept" = "application/json;api-version=5.0-preview.4;excludeUrls=true" }
    
    $definition = [PSCustomObject]@{
        'id' = $BuildDefinitionId
    }
    
    $queue = @{
        'id' = (Get-BuildDefinitions -vstsAccount $vstsAccount -projectName $projectName -PATToken $PATToken -DefinitionIds $BuildDefinitionId).value.queue.id
    }
    
    $project = @{
        'id' = (Get-ProjectDetails -vstsAccount $vstsAccount -PATToken $PATToken -projectName $projectName).id
    }
    
    $params = @()
    foreach ($item in $Parameters.Keys) {
        $params += "\`"$($item)\`":\`"$($Parameters[$item])\`""
    }
  
    $body = [PSCustomObject]@{
        queue        = $queue
        definition   = $definition
        project      = $project
        sourceBranch = $SourceBranch
        reason       = 1
        parameters   = "{$($params -join ',')}"
    }
  
    $body = $body | ConvertTo-Json
  
    $BuildInfo = Invoke-RestMethod -Uri "https://$($vstsAccount).visualstudio.com/$($projectName)/_apis/build/builds?ignoreWarnings=false" -Method Post -Body $body -ContentType "application/json" -Headers $Header
}


Export-ModuleMember -Function Get-UnusedTaskGroups, Get-BuildAnalysis, Get-AzurePowershellVersionAnalysis, Start-Build, Get-BuildDefinitions, Get-TaskGroups, Get-TaskGroup, ConvertTo-NewPowerShellVersionTask