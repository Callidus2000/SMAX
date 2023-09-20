function Get-SMAXEntity {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byFilter")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
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
        # $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"
        # $validProperties = $definitions.$EntityName.properties |  Select-Object -ExpandProperty name
        # $layout=$validProperties | Join-String -Separator ','
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
        LoggingActionValues    = @($EntityName, $Properties,$Filter)
        method                 = "GET"
        Path                   = "/ems/$EntityName"
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
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json)"
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