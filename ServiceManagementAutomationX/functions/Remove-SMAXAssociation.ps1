function Remove-SMAXAssociation {
    <#
    .SYNOPSIS
    Removes a MANY2MANY relationship between two entities.

    .DESCRIPTION
    Removes a MANY2MANY relationship between two entities (N:M).

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
    Remove-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 388154

    Removes the person 388154 to the Request 400551 as a follower.

    .EXAMPLE
    Remove-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 388154 -BulkID MyBulk
    Remove-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 115 -BulkID MyBulk
    Remove-SMAXAssociation -BulkID MyBulk -ExecuteBatch

    Removes the persons 388154 and 115 to the Request 400551 as a follower in a single web request.

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
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "executeBulk")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "BuildBulk")]
        [string]$BulkID,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "executeBulk")]
        [switch]$ExecuteBulk
    )
    $bulkParameter = $PSBoundParameters | ConvertTo-PSFHashtable
    $bulkParameter.Operation = 'Delete'
    Edit-SMAXAssociation @bulkParameter
}