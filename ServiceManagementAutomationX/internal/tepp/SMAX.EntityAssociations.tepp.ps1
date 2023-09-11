Register-PSFTeppScriptblock -Name "SMAX.EntityAssociations" -ScriptBlock {
    try {
        $connection = Get-SMAXLastConnection
        $entityName = $fakeBoundParameter.EntityName
        if ([string]::IsNullOrEmpty($entityName)) { return }

        $definitions = Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).tepp.EntityAssociations"
        if (-not $definitions.containskey($entityName)) { return }
        # Write-PSFMessage "$entityName>$wordToComplete"
        if ($wordToComplete -match "([^.]+)\..*") {
            $subPropName = $wordToComplete -replace "([^.]+)\..*", '$1'
            if ($definitions.containskey("$entityName.$subPropName")) {
                # Write-PSFMessage "$entityName>>$subPropName"
                # Write-PSFMessage "`$definitions.`"$entityName.$subPropName`""
                return $definitions."$entityName.$subPropName" #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
            }
        }
        return $definitions.$entityName #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
    }
    catch {
        return "Error"
    }
}
