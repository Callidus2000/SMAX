Register-PSFTeppScriptblock -Name "SMAX.EntityNames" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)) {
            $connection = Get-SMAXLastConnection
        }
        else {
            $connection = $fakeBoundParameter.Connection
        }
        if ($commandName -match 'SMAXComment') {
            # Return only definitions which have a Comments property
            $definitions = Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).entityDefinition"
            return ($definitions.Values | Where-Object { $_.properties.name -contains 'Comments' } | Select-Object -ExpandProperty name)
        }
        return Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).tepp.EntryNames" #| Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName } }
    }
    catch {
        return "Error"
    }
}
