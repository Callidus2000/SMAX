function Add-SMAXAssociation {
    <#
    .SYNOPSIS
    Modifies a MANY2MANY relationship between two entities.

    .DESCRIPTION
    Modifies a MANY2MANY relationship between two entities (N:M).

    .PARAMETER Connection
    The connection to SMAX

    .PARAMETER EnableException
    If set to $true, an exception will be thrown in case of an error

    .PARAMETER EntityName
    The name of the entity (N)

    .PARAMETER EntityId
    The ID of the (N) entity

    .PARAMETER RemoteId
    The ID of the remote entity (M) which is associated to the first (N)

    .PARAMETER Association
    The Name of the association attribute of the main entity (N)

    .PARAMETER BulkID
    For bulk processing: The ID of the current batch

    .PARAMETER ExecuteBulk
    For bulk processing: execute all stored changes

    .EXAMPLE
    Add-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 388154

    Adds the person 388154 to the Request 400551 as a follower.

    .EXAMPLE
    Add-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 388154 -BulkID MyBulk
    Add-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 115 -BulkID MyBulk
    Add-SMAXAssociation -BulkID MyBulk -ExecuteBatch

    Adds the persons 388154 and 115 to the Request 400551 as a follower in a single web request.

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "singleAssociation")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "BuildBulk")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
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
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "singleAssociation")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "executeBulk")]
        [ValidateSet('Create', 'Delete')]
        [string]$Operation,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "executeBulk")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "BuildBulk")]
        [string]$BulkID,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "executeBulk")]
        [switch]$ExecuteBulk
    )
    $bulkParameter = $PSBoundParameters | ConvertTo-PSFHashtable
    $bulkParameter.Operation = 'Create'
    Edit-SMAXAssociation @bulkParameter
}