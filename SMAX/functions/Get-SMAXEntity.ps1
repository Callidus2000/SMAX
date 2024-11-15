function Get-SMAXEntity {
    <#
    .SYNOPSIS
        Retrieves data entities from the Micro Focus SMAX API.

    .DESCRIPTION
        The Get-SMAXEntity function retrieves data entities from the Micro Focus SMAX
        API. You can specify the entity name, properties to retrieve, filtering
        criteria, sorting order, and other options. It supports two parameter sets:
        "byFilter" for filtering by criteria and "byEntityId" for retrieving a
        specific entity by its ID.

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
        Specifies the name of the entity to retrieve. This parameter supports tab
        completion using SMAX.EntityTypes.

    .PARAMETER Properties
        Specifies the properties to retrieve for the entity. This parameter supports
        tab completion using SMAX.EntityProperties. Use '*' to retrieve all
        properties or specify individual properties as an array.

    .PARAMETER Filter
        Specifies a filter criteria for selecting entities. Only applicable when
        using the "byFilter" parameter set.

    .PARAMETER Order
        Specifies sorting order for the retrieved entities. Only applicable when
        using the "byFilter" parameter set.

    .PARAMETER Id
        Specifies the ID of the entity to retrieve. Only applicable when using the
        "byEntityId" parameter set.

    .PARAMETER FlattenResult
        If specified, the result is flattened, and only the properties are returned.

    .EXAMPLE
        Get-SMAXEntity -EntityType "Incident" -Properties "*" -Filter "Status='New'"

        Description:
        Retrieves all properties of new incidents.

    .EXAMPLE
        Get-SMAXEntity -EntityType "User" -Properties "Name", "Email" -Order "Name"

        Description:
        Retrieves the name and email properties of users, sorted by name.

    .NOTES
        Date:   September 28, 2023
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byFilter")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byFilter")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityProperties")]
        [string[]]$Properties,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byFilter")]
        [string]$Filter,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byFilter")]
        [string]$Order,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [int]$Id,
        [switch]$FlattenResult
    )
    if($Properties -contains '*'){
        $layout="FULL_LAYOUT"
    }else{
        $layout = $Properties | Join-String -Separator ','
    }
    $apiCallParameter = @{
        EnableException        = $EnableException
        EnablePaging           = $EnablePaging
        Connection             = $Connection
        ConvertJsonAsHashtable = $false
        LoggingAction          = "Get-SMAXEntity"
        LoggingActionValues    = @($EntityType, $Properties,$Filter)
        method                 = "GET"
        Path                   = "/ems/$EntityType"
        URLParameter           = @{
            layout = $layout
        }
    }
    switch ($PsCmdlet.ParameterSetName) {
        'byEntityId'{
            $apiCallParameter.Path = $apiCallParameter.Path+"/$Id"
        }
        default{
            if (-not [string]::IsNullOrEmpty($Filter)) {
                $apiCallParameter.URLParameter.filter = $Filter
            }
            if (-not [string]::IsNullOrEmpty($Order)) {
                $apiCallParameter.URLParameter.order = $Order
            }
        }
    }
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -WarningAction SilentlyContinue)"
    $result = Invoke-SMAXAPI @apiCallParameter | Where-Object { $_.properties}
    foreach ($item in $result) {
        Add-Member -InputObject $item.properties -MemberType NoteProperty -Name related -Value $item.related_properties
        $item.properties.PSObject.TypeNames.Insert(0, "SMAX.$($item.entity_type)")
    }
    if($FlattenResult){
        return $result.properties|ConvertTo-SMAXFlatObject
    }

    return $result.properties

}