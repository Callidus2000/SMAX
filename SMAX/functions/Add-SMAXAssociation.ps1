function Add-SMAXAssociation {
    <#
    .SYNOPSIS
    Adds associations between entities in the Service Management Automation X (SMAX) platform.

    .DESCRIPTION
    The Add-SMAXAssociation function allows you to create associations between entities in SMAX.
    You can specify the entity names, IDs, association type, and bulk operation parameters.

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .PARAMETER EntityType
    Specifies the name of the source entity from which the association is created.

    .PARAMETER EntityId
    Specifies the ID of the source entity from which the association is created.

    .PARAMETER RemoteId
    Specifies the ID of the remote entity to associate with.

    .PARAMETER Association
    Specifies the type of association between the entities.

    .PARAMETER BulkID
    Specifies the bulk operation ID when performing a bulk association operation.

    .PARAMETER ExecuteBulk
    Indicates whether to execute a bulk association operation.

    .EXAMPLE
    PS C:\> Add-SMAXAssociation -Connection $conn -EntityType "Incident" -EntityId 123 -RemoteId 456 -Association "RelatesTo"

    This example creates an association between an incident with ID 123 and another entity with ID 456 of type "RelatesTo."
    .EXAMPLE
    Add-SMAXAssociation -EntityType Request -EntityId 400551 -Association FollowedByUsers -remoteId 388154 -BulkID MyBulk
    Add-SMAXAssociation -EntityType Request -EntityId 400551 -Association FollowedByUsers -remoteId 115 -BulkID MyBulk
    Add-SMAXAssociation -BulkID MyBulk -ExecuteBatch

    Adds the persons 388154 and 115 to the Request 400551 as a follower in a single web request.

    .NOTES
    File Name      : Add-SMAXAssociation.ps1

    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "singleAssociation")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "BuildBulk")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "singleAssociation")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "BuildBulk")]
        [int]$EntityId,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "singleAssociation")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "BuildBulk")]
        [int]$RemoteId,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "singleAssociation")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "BuildBulk")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityAssociations")]
        [string]$Association,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "executeBulk")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "BuildBulk")]
        [string]$BulkID,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "executeBulk")]
        [switch]$ExecuteBulk
    )
    $bulkParameter = $PSBoundParameters | ConvertTo-PSFHashtable
    if ($PsCmdlet.ParameterSetName -ne 'BuildBulk') {
        $bulkParameter.Operation = 'Create'
    }
    # Write-PSFMessage "`$bulkParameter=$($bulkParameter|ConvertTo-PSFHashtable -Exclude Connection|ConvertTo-Json -WarningAction SilentlyContinue -Compress)" -Level Critical
    Edit-SMAXAssociation @bulkParameter
}