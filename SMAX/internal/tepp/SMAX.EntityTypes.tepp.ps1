<#
.SYNOPSIS
Registers a PSFramework Tab Expansion Plus Plus (TEPP) script block for
SMAX entity types.

.DESCRIPTION
The TEPP script block retrieves all entity types from the SMAX configuration.
If the command name matches 'SMAXComment', it returns only those definitions
that have a 'Comments' property. The TEPP is used to provide dynamic
completion for entity types in SMAX.
#>
Register-PSFTeppScriptblock -Name "SMAX.EntityTypes" -ScriptBlock {
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
