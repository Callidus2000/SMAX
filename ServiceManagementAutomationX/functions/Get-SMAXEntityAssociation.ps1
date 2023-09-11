function Get-SMAXEntityAssociation {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
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
        LoggingActionValues    = @($EntityName, $Properties,$Filter)
        method                 = "GET"
        Path                   = "/ems/$EntityName/$id/associations/$Association"
        URLParameter           = @{
            layout = $Properties | Join-String -Separator ','
        }
    }

    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json)"
    $result = Invoke-SMAXAPI @apiCallParameter | Where-Object { $_.properties}
    foreach ($item in $result) {
        Add-Member -InputObject $item.properties -MemberType NoteProperty -Name related -Value $item.related_properties
        $item.properties.PSObject.TypeNames.Insert(0, "SMAX.$($item.entity_type)")
    }

    return $result.properties

}