function Get-SMAXEntity {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [string[]]$Properties,
        [string]$Filter,
        [switch]$Interactive
    )
    if ($Interactive) {
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
        LoggingAction          = "Add-SMAXAddress"
        # LoggingActionValues = @($addressList.count, $explicitADOM)
        method                 = "GET"
        Path                   = "/ems/$EntityName"
        # Path            = "/ems/Incident?layout=Id,Status,OwnedByPerson,OwnedByPerson.Name,OwnedByPerson.Email"
        URLParameter           = @{
            layout = $Properties | Join-String -Separator ','
        }
    }
    if (-not [string]::IsNullOrEmpty($Filter)) {
        $apiCallParameter.URLParameter.filter = $Filter
    }
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json)"
    $result = Invoke-SMAXAPI @apiCallParameter
    return $result

}