function Get-SMAXEntityAssociation {
    <#
    .SYNOPSIS
        Retrieves entity associations from the Micro Focus SMAX API.

    .DESCRIPTION
        The Get-SMAXEntityAssociation function retrieves associations for a specified
        entity from the Micro Focus SMAX API. You can specify the entity name,
        association type, properties to retrieve, and other options.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it
        will use the last saved connection obtained using the Get-SMAXLastConnection
        function.

    .PARAMETER EnableException
        Indicates whether to enable exception handling. If set to $true (default),
        the function will throw exceptions on API errors. If set to $false, it will
        return error information as part of the result.

    .PARAMETER EnablePaging
        Enables paging for large result sets. By default, paging is enabled.

    .PARAMETER EntityType
        Specifies the name of the entity for which associations are retrieved. This
        parameter supports tab completion using SMAX.EntityTypes.

    .PARAMETER Properties
        Specifies the properties to retrieve for the entity associations. This
        parameter supports tab completion using SMAX.EntityAssociationProperties.

    .PARAMETER Association
        Specifies the type of association to retrieve. This parameter supports tab
        completion using SMAX.EntityAssociations.

    .PARAMETER Id
        Specifies the ID of the entity for which associations are retrieved.

    .EXAMPLE
        Get-SMAXEntityAssociation -EntityType "Incident" -Association "linked_ci" -Id 123

        Description:
        Retrieves associations of the "linked_ci" type for the incident with ID 123.

    .EXAMPLE
        Get-SMAXEntityAssociation -EntityType "Change" -Association "related_changes" -Id 456
        -Properties "Title", "Status"

        Description:
        Retrieves the "Title" and "Status" properties of related changes for the change
        with ID 456.

    .NOTES
        Date:   September 28, 2023
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityAssociationProperties")]
        [string[]]$Properties,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityAssociations")]
        [string]$Association,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [int]$Id
    )
    $apiCallParameter = @{
        EnableException        = $EnableException
        EnablePaging           = $EnablePaging
        Connection             = $Connection
        ConvertJsonAsHashtable = $false
        LoggingAction          = "Get-SMAXEntity"
        LoggingActionValues    = @($EntityType, $Properties,$Filter)
        method                 = "GET"
        Path                   = "/ems/$EntityType/$id/associations/$Association"
        URLParameter           = @{
            layout = $Properties | Join-String -Separator ','
        }
    }

    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -WarningAction SilentlyContinue)"
    $result = Invoke-SMAXAPI @apiCallParameter | Where-Object { $_.properties}
    foreach ($item in $result) {
        Add-Member -InputObject $item.properties -MemberType NoteProperty -Name related -Value $item.related_properties
        $item.properties.PSObject.TypeNames.Insert(0, "SMAX.$($item.entity_type)")
    }

    return $result.properties

}