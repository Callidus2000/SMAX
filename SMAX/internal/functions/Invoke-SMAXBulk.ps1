function Invoke-SMAXBulk {
    <#
    .SYNOPSIS
    Performs bulk create or update operations on entities in the Service Management Automation X (SMAX) platform.

    .DESCRIPTION
    The Invoke-SMAXBulk function allows you to perform bulk create or update operations on SMAX entities.
    You can specify the entity name, input objects, and the operation type (Create or Update).

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .PARAMETER EntityType
    Specifies the name of the entity for which the bulk operation is performed.

    .PARAMETER InputObject
    Specifies the entities to be created or updated. You can provide an array of SMAX entity objects.
    They all have to be from the EntityType

    .PARAMETER Operation
    Specifies the operation type. It can be either "Create" or "Update."

    .EXAMPLE
    PS C:\> $newEntities = @(
        @{
            Title = "New Incident 1"
            Description = "This is a new incident 1"
            Category = "Service Request"
        },
        @{
            Title = "New Incident 2"
            Description = "This is a new incident 2"
            Category = "Incident"
        }
    )
    PS C:\> Invoke-SMAXBulk -Connection $conn -EntityType "Incident" -InputObject $newEntities -Operation "Create"

    This example performs a bulk creation operation for two new incidents.

    .EXAMPLE
    PS C:\> $updatedEntities = @(
        @{
            Id = 123
            Title = "Updated Incident 1"
        },
        @{
            Id = 456
            Title = "Updated Incident 2"
        }
    )
    PS C:\> Invoke-SMAXBulk -Connection $conn -EntityType "Incident" -InputObject $updatedEntities -Operation "Update"

    This example performs a bulk update operation for two existing incidents.

    .NOTES
    File Name      : Invoke-SMAXBulk.ps1

    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
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
    }
    process {
        Write-PSFMessage "processing `$InputObject: $($InputObject|ConvertTo-Json -WarningAction SilentlyContinue -Compress -Depth 4)"
        foreach ($obj in $InputObject) {
            Write-PSFMessage "processing `$Obj: $($obj|ConvertTo-Json -WarningAction SilentlyContinue -Compress -Depth 4)"
            $localEntityName = $obj.psobject.TypeNames -match '^SMAX' -replace 'SMAX\.' | Select-Object -First 1
            if ([string]::IsNullOrEmpty($localEntityName)) {
                if ([string]::IsNullOrEmpty($EntityType)) {
                    Stop-PSFFunction -EnableException $EnableException -Message "Neither `$_.PSDataType nor -EntityType param set for object $($obj|ConvertTo-Json -WarningAction SilentlyContinue -Compress -Depth 4)"
                    continue
                }
                $localEntityName = $EntityType
            }
            $validProperties = $definitions.$localEntityName.properties | Where-Object readonly -eq $false | Select-Object -ExpandProperty name
            if ($Operation -eq 'Update') { $validProperties += 'Id' }
            Write-PSFMessage "`$validProperties=$($validProperties -join ',')"
            $entity = [PSCustomObject]@{
                "entity_type" = $localEntityName
                "properties"  = $obj | ConvertTo-PSFHashtable -Include $validProperties
            }
            Write-PSFMessage "adding `$entity: $($entity|ConvertTo-Json -WarningAction SilentlyContinue -Compress -Depth 4)"
            [void]$entityList.Add($entity)
        }
    }
    end {
        Write-PSFMessage "Count of entities: $($entityList.count)"
        Write-PSFMessage "$($entityList|ConvertTo-Json -WarningAction SilentlyContinue)"
        $apiCallParameter = @{
            EnableException        = $EnableException
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
        Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5)"
        $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
        Write-PSFMessage "`$result=$($result|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5)"

        return $result
    }

}