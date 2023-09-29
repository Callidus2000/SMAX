function Update-SMAXEntity {
    <#
    .SYNOPSIS
    Updates entities in the Service Management Automation X (SMAX) platform.

    .DESCRIPTION
    The Update-SMAXEntity function allows you to update one or more entities in SMAX.
    You can specify the entity name and provide an array of input objects to update.

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .PARAMETER EntityName
    Specifies the name of the entity to update. This parameter is optional if the
    PSCustomObject has a PSTypeName 'SMAX.{entityname}'

    .PARAMETER InputObject
    Specifies the entities to update. You can provide an array of SMAX entity objects.
    They have to be from the same type

    .EXAMPLE
    PS C:\> $entity = Get-SMAXEntity -Connection $conn -EntityName "Incident" -Id "123" -Properties *
    PS C:\> $entity.Status = "Closed"
    PS C:\> Update-SMAXEntity -Connection $conn -EntityName "Incident" -InputObject $entity

    This example retrieves an incident entity, updates its status to "Closed," and then
    applies the changes to the SMAX platform.

    .NOTES
    File Name      : Update-SMAXEntity.ps1

#>
<#
    .SYNOPSIS
    Updates existing entities.

    .DESCRIPTION
    Updates existing entities.

    .PARAMETER Connection
    The connection to SMAX

    .PARAMETER EnableException
    If set to $true, an exception will be thrown in case of an error

    .PARAMETER EntityName
    The name of the entity (N).
    Can be ommited if the PSCustomObject has a PSTypeName 'SMAX.{entityname}'

    .PARAMETER InputObject
    The new object to be created. Either a CustomObject or a HashTable with the new properties.

    .EXAMPLE
    $request=Get-SMAXEntity -Connection $connection -EntityName Request -Id 47
    # ... Setting the properties
    $request|Update-SMAXEntity -Connection $connection -EntityName Request


    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [parameter(mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "byEntityId")]
        [object[]]$InputObject
    )
    begin {
        $entityList = @()
        $bulkParameter = $PSBoundParameters | ConvertTo-PSFHashtable -Exclude LoggingActionValues, RevisionNote, LoggingAction, InputObject
        $bulkParameter.Operation = 'Update'
        # $InputObject | ForEach-Object { "BeginUpdate $($_.Id), Typenames= $($_.psobject.TypeNames -join ',')" | Out-Host }
        # Write-PSFMessage "BeginUpdate `$InputObject.Gettype(): $($InputObject.GetType())"
    }
    process {

        $entityList += $InputObject
    }
    end {
        $bulkParameter.InputObject = $entityList
        # $bulkParameter.InputObject | ForEach-Object { "EndUpdate $($_.Id), Typenames= $($_.psobject.TypeNames -join ',')" | Out-Host }
        Invoke-SMAXBulk @bulkParameter
    }
}