function Get-SMAXEntity {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byFilter")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byFilter")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityProperties")]
        [string[]]$Properties,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byFilter")]
        [string]$Filter,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [int]$Id,
        [switch]$FlattenResult
    )

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
            layout = $Properties | Join-String -Separator ','
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