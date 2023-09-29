function Add-SMAXEntity {
    <#
    .SYNOPSIS
    Adds entities to the Service Management Automation X (SMAX) platform.

    .DESCRIPTION
    The Add-SMAXEntity function allows you to create new entities in the SMAX platform.
    You can specify the entity type name and provide an array of input objects to create.

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .PARAMETER EntityName
    Specifies the name of the entity to create. This parameter is optional when using
    the pipeline to provide input objects.

    .PARAMETER InputObject
    Specifies the entities to create. You can provide an array of SMAX entity objects.

    .EXAMPLE
    PS C:\> $newEntity = @{
        Title = "New Incident",
        Description = "This is a new incident",
        Category = "Service Request"
    }
    PS C:\> Add-SMAXEntity -Connection $conn -EntityName "Incident" -InputObject $newEntity

    This example creates a new incident entity with the specified properties.

    .NOTES
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
        $bulkParameter.Operation = 'Create'
    }
    process {
        $entityList += $InputObject
    }
    end {
        $bulkParameter.InputObject = $entityList
        Invoke-SMAXBulk @bulkParameter
    }
}