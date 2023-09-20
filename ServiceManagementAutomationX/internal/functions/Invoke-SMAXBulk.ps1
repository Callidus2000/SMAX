function Invoke-SMAXBulk {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [parameter(mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "byEntityId")]
        [object[]]$InputObject,
       	[ValidateSet('Create', 'Update')]
        [string]$Operation
    )
    begin {
        $entityList = new System.Collections.ArrayList
        $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"
        if([string]::IsNullOrEmpty($definitions)){
            Stop-PSFFunction -EnableException $EnableException -Message "SMAX Entitymodel not initialized, please run Initialize-SMAXEntityModel"
        }
        Write-PSFMessage "Load Definition $(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"
        # $definitions|json|Set-Clipboard
        # Write-PSFMessage "BeginBulk `$InputObject.Gettype(): $($InputObject.GetType())"
        # Write-PSFMessage "BeginBulk `$InputObject: $($InputObject|ConvertTo-Json -Compress -Depth 4)"
        # $InputObject | ForEach-Object { "BeginBulk $($_.Id), Typenames= $($_.psobject.TypeNames -join ',')" | Out-Host }
    }
    process {
        Write-PSFMessage "processing `$InputObject: $($InputObject|ConvertTo-Json -Compress -Depth 4)"
        # if ([string]::IsNullOrEmpty($EntityName)) {
        #     Write-PSFMessage "Checking if each data object has set a PSDatatype"
        #     foreach ($obj in $InputObject) {
        #         $InputObject | ForEach-Object { "ProcessBulk $($obj.Id), Typenames= $($obj.psobject.TypeNames -join ',')" | Out-Host }
        #         $countWithTypenames = ($obj | Where-Object { $_.psobject.TypeNames -match '^SMAX' } | Measure-Object).count
        #         $InputObjectCount = ($obj | Measure-Object).count
        #         Write-PSFMessage "`$InputObjectCount=$obj, `$countWithTypenames=$countWithTypenames"
        #         if ($countWithTypenames -ne $InputObjectCount) {
        #             Stop-PSFFunction -EnableException $EnableException -Message "Neither `$_.PSDataType nor -EntityName param set"
        #             $entityList.Clear()
        #             return
        #         }
        #     }
        # }
        foreach ($obj in $InputObject) {
            Write-PSFMessage "processing `$Obj: $($obj|ConvertTo-Json -Compress -Depth 4)"
            $localEntityName = $obj.psobject.TypeNames -match '^SMAX' -replace 'SMAX\.' | Select-Object -First 1
            if ([string]::IsNullOrEmpty($localEntityName)) {
                if ([string]::IsNullOrEmpty($EntityName)) {
                    Stop-PSFFunction -EnableException $EnableException -Message "Neither `$_.PSDataType nor -EntityName param set for object $($obj|ConvertTo-Json -Compress -Depth 4)"
                    continue
                }
                $localEntityName = $EntityName
            }
            $validProperties = $definitions.$localEntityName.properties | Where-Object readonly -eq $false | Select-Object -ExpandProperty name
            if ($Operation -eq 'Update') { $validProperties += 'Id' }
            Write-PSFMessage "`$validProperties=$($validProperties -join ',')"
            $entity = [PSCustomObject]@{
                "entity_type" = $localEntityName
                "properties"  = $obj | ConvertTo-PSFHashtable -Include $validProperties
            }
            Write-PSFMessage "adding `$entity: $($entity|ConvertTo-Json -Compress -Depth 4)"
            [void]$entityList.Add($entity)
        }
    }
    end {
        Write-PSFMessage "Count of entities: $($entityList.count)"
        Write-PSFMessage "$($entityList|json)"
        $apiCallParameter = @{
            EnableException        = $EnableException
            # EnablePaging           = $EnablePaging
            Connection             = $Connection
            ConvertJsonAsHashtable = $false
            LoggingAction          = "Invoke-SMAXBulk"
            LoggingActionValues    = @($Operation, $entityList.Count)
            method                 = "POST"
            Path                   = "/ems/bulk"
            body                   = @{
                entities  = $entityList.ToArray()
                operation = $Operation.ToUpper()
            }
        }
        Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -Depth 5)"
        $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
        Write-PSFMessage "`$result=$($result|ConvertTo-Json -Depth 5)"

        return $result
    }

}