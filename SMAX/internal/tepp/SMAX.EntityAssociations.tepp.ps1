Register-PSFTeppScriptblock -Name "SMAX.EntityAssociations" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)) {
            $connection = Get-SMAXLastConnection -EnableException $false
        }
        else {
            $connection = $fakeBoundParameter.Connection
        }
        $EntityType = $fakeBoundParameter.EntityType
        if ([string]::IsNullOrEmpty($EntityType)) { return }

        $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).tepp.EntityAssociations"
        if (-not $definitions.containskey($EntityType)) { return }
        # Write-PSFMessage "$EntityType>$wordToComplete"
        if ($wordToComplete -match "([^.]+)\..*") {
            $subPropName = $wordToComplete -replace "([^.]+)\..*", '$1'
            if ($definitions.containskey("$EntityType.$subPropName")) {
                # Write-PSFMessage "$EntityType>>$subPropName"
                # Write-PSFMessage "`$definitions.`"$EntityType.$subPropName`""
                return $definitions."$EntityType.$subPropName" #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
            }
        }
        return $definitions.$EntityType #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
    }
    catch {
        return "Error $_"
    }
}
