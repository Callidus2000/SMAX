function Edit-SMAXAssociation {
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

    .PARAMETER Operation
    Create/Delete: Should a new relation be added (Create) or removed (Delete)

    .PARAMETER BulkID
    For bulk processing: The ID of the current batch

    .PARAMETER ExecuteBulk
    For bulk processing: execute all stored changes

    .EXAMPLE
    Edit-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 388154 -Operation Create

    Adds the person 388154 to the Request 400551 as a follower.

    .EXAMPLE
    Edit-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 388154 -BulkID MyBulk
    Edit-SMAXAssociation -EntityName Request -EntityId 400551 -Association FollowedByUsers -remoteId 115 -BulkID MyBulk
    Edit-SMAXAssociation -BulkID MyBulk -Operation Create -ExecuteBatch

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
    if (-not $ExecuteBulk){
        Write-PSFMessage "No Bulk Execution, creating new relationship object"
        $definitions = Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).entityDefinition"
        if ([string]::IsNullOrEmpty($definitions)) {
            Stop-PSFFunction -EnableException $EnableException -Message "SMAX Entitymodel not initialized, please run Initialize-SMAXEntityModel"
        }
        $secondEndpoint = $definitions.$EntityName.associations | Where-Object name -eq $Association | Select-Object -ExpandProperty linkEntityName
        if ([string]::IsNullOrEmpty($secondEndpoint)) {
            Stop-PSFFunction -EnableException $EnableException -Message "Could not find secondEndpoint for '$EntityName' association '$Association'"
        }
        $newRel = [PSCustomObject]@{
            name           = $Association
            firstEndpoint  = [PSCustomObject]@{
                $EntityName = $EntityId
            }
            secondEndpoint = [PSCustomObject]@{
                $secondEndpoint = $RemoteId
            }
        }
    }
    switch -regex ($PSCmdlet.ParameterSetName){
        "singleAssociation"{
            Write-PSFMessage "SingleRelation"
            $relationships=@($newRel)
            # $relationships = new System.Collections.ArrayList
        }
        'Bulk'{
            if([string]::IsNullOrEmpty($Script:EntAssBulks)){
                Write-PSFMessage "Initialisiere `$Script:EntAssBulks"
                $Script:EntAssBulks=@{}
            }
            if ($Script:EntAssBulks.containskey($BulkID)){
                Write-PSFMessage "Using existing Bulk Collection $BulkID"
                $relationships=$Script:EntAssBulks.$BulkID
            }
            else{
                Write-PSFMessage "Starting Bulk Collection $BulkID"
                $relationships = new System.Collections.ArrayList
                $Script:EntAssBulks.$BulkID = $relationships
            }
        }
        'BuildBulk'{
            [void]$relationships.add($newRel)
            return
        }
        'executeBulk'{
            if ([string]::IsNullOrEmpty($relationships)){
                # Write-PSFMessage -Level Warning
                Stop-PSFFunction -Message "No Bulk Data for '$BulkID' available" -EnableException $EnableException
                return
            }
        }
    }
    $apiCallParameter = @{
        EnableException        = $EnableException
        # EnablePaging           = $EnablePaging
        Connection             = $Connection
        ConvertJsonAsHashtable = $false
        LoggingAction          = "Edit-SMAXAssociation"
        LoggingActionValues    = @($Operation, $relationships.Count)
        method                 = "POST"
        Path                   = "/ems/bulk"
        body                   = @{
            relationships = $relationships
            operation     = $Operation.ToUpper()
        }
    }
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -Depth 5)"
    $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
    Write-PSFMessage "`$result=$($result|ConvertTo-Json -Depth 5)"

    if($ExecuteBulk){
        Write-PSFMessage "Bulk executed, clearing temp. cache"
        $Script:EntAssBulks.remove($BulkID)
    }
    return $result
}