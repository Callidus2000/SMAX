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
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "interactive")]
        [switch]$Interactive
    )
    if ($PsCmdlet.ParameterSetName -eq 'interactive') {
        $chosenEntityName = (Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).entityDefinition").values | Select-Object @{name = "Entity"; expression = { $_.Name } }, @{name = "Localized Name"; expression = { $_.LocName } }  | Out-GridView -OutputMode Single -Title "Choose entity" | Select-Object -ExpandProperty Entity
        if ($chosenEntityName) {
            $chosenAttributes = (Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).entityDefinition").$chosenEntityName.properties | Select-Object @{name = "Property"; expression = { $_.Name } }, @{name = "Localized Name"; expression = { $_.LocName } }  | Out-GridView -OutputMode Multiple -Title "Choose Properties" | Select-Object -ExpandProperty Property
            if ($chosenAttributes) {
                Write-PSFMessage -Level Host "Get-SMAXEntity -Connection `$Connection -EntityName $chosenEntityName -Properties $($chosenAttributes|add-string -Before "'" -Behind "'"|join-string -Separator ',')"
            }
        }
        [string]::IsNullOrEmpty()
        return
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

    return $result.properties

}