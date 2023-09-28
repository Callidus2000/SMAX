function Remove-SMAXAssociation {
    <#
    .SYNOPSIS
        Removes an association between entities in Micro Focus SMAX.

    .DESCRIPTION
        The Remove-SMAXAssociation function allows you to remove an association between
        entities in Micro Focus SMAX. You can remove a single association or perform
        bulk association removal by specifying parameters accordingly.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it
        will use the last saved connection obtained using the Get-SMAXLastConnection
        function.

    .PARAMETER EnableException
        Indicates whether exceptions should be enabled. Default is $true.

    .PARAMETER EntityName
        Specifies the name of the entity for which the association needs to be removed.

    .PARAMETER EntityId
        Specifies the ID of the entity from which the association originates.

    .PARAMETER RemoteId
        Specifies the ID of the remote entity involved in the association.

    .PARAMETER Association
        Specifies the type of association to be removed.

    .PARAMETER BulkID
        Specifies the bulk operation ID when performing bulk association removal.

    .PARAMETER ExecuteBulk
        Indicates whether to execute the bulk association removal operation.

    .EXAMPLE
        # Remove a single association between two entities.
        Remove-SMAXAssociation -EntityName "Incident" -EntityId 123 -RemoteId 456 -Association "RelatedIncident"

        Description:
        Removes the "RelatedIncident" association between the Incident with EntityId 123
        and the Incident with EntityId 456.

    .EXAMPLE
        # Build a bulk association removal operation.
        $bulkParams = @{
            EntityName = "Change"
            EntityId   = 789
            RemoteId   = 987
            Association = "RelatedChange"
            BulkID     = "BulkOperation123"
        }
        Remove-SMAXAssociation @bulkParams
        $bulkParams = @{
            EntityName = "Change"
            EntityId   = 789
            RemoteId   = 123
            Association = "RelatedChange"
            BulkID     = "BulkOperation123"
        }
        Remove-SMAXAssociation @bulkParams
        Remove-SMAXAssociation -BulkID "BulkOperation123" -ExecuteBulk

        Description:
        Builds a bulk association removal operation to remove the "RelatedChange"
        association between the Change with EntityId 789 and the Change with EntityId 987 and 123
        in a single web request.

    .NOTES
        Date:   September 28, 2023
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