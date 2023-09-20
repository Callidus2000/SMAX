Register-PSFTeppScriptblock -Name "SMAX.EntityNames" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)) {
            $connection = Get-SMAXLastConnection -EnableException $false
        }
        else {
            $connection = $fakeBoundParameter.Connection
        }
        if ($commandName -match 'SMAXComment') {
            # Return only definitions which have a Comments property
            $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"
            return ($definitions.Values | Where-Object { $_.properties.name -contains 'Comments' } | Select-Object -ExpandProperty name)
        }
        return Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).tepp.EntryNames" #| Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName } }
    }
    catch {
        return "Error $_"
    }
}
