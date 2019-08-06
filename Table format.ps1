$Query = @(
    "select top 50 Id,ReferenceId,IsAuthorized,UId,DisplayName from ums.users",
    0,
    "Stuck processes with no assignees for authorized subjects in the DB"
)
$SqlServer = "YFO-Stark-Test.database.windows.net"
$User = "rootuser"
$Password = "youforce1!"
$DatabaseI = "YFO-Stark-Test-Client1"
$ShowScript = $true

$connectionString = "Data Source=$SqlServer;Initial Catalog=$DatabaseI;User ID=$User;Password=$Password;Connection Timeout=90"
Write-Debug -Message "Connectionstring: $connectionString"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)

$Command = New-Object -TypeName System.Data.SqlClient.SqlCommand($Query[0], $connection)
If ($ShowScript) { Write-Output -InputObject $Query[0] }
Write-Output -InputObject 'Opening connection and executing query'
$connection.Open()

$Adapter = New-Object System.Data.sqlclient.sqlDataAdapter $Command
$Dataset = New-Object System.Data.DataSet
Try {
    $Adapter.Fill($DataSet) | Out-Null
    #If($Dataset.tables[0].Rows[0][0] -ne $Query[1]){
    #}
      
    $RowContent = @()
      
    for ($count = 0; $count -lt $Dataset.Tables.Count; $count++) {
      $Dataset.Tables.Count
        $table = $Dataset.Tables[$count];
        #$ci = $table.Columns |ForEach-Object {$t = @{}} {$t[$_.ColumnName] = $_.Ordinal} {return $t}
        $table | ConvertTo-CSV -NoTypeInformation -OutVariable TableOutput | clip.exe
        ($TableOutput -join '\n\n') | ConvertTo-Json -OutVariable JsonFormat -Depth 100 | clip.exe
 
        
        # foreach ($dr in $table.Rows) {
        #     $RowContent = @()
        #     foreach ($column in $table.Columns) {

        #         $RowContent += $dr[$column]

        #     }
        #     (($ci.GetEnumerator() | Sort-Object -Property Value) | ForEach-Object {$_.Name}) -join ','
        #     $RowContent -join ","
        # }
    }
      
}
Catch {
    Write-Output -InputObject 'Error executing query'
    Write-Output -InputObject $_.Exception
}  
Write-Output -InputObject 'Closing connection'
$connection.Close()