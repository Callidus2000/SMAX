Register-PSFTeppScriptblock -Name "SMAX.EntityProperties" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)) {
            $connection = Get-SMAXLastConnection
        }
        else {
            $connection = $fakeBoundParameter.Connection
        }
        $entityName = $fakeBoundParameter.EntityName
        if ([string]::IsNullOrEmpty($entityName)){return}
        switch ($commandName){
            'New-SMAXEntity' {
                $definitions = Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).entityDefinition"
                return $definitions.$entityName.properties | where-object required -eq $false | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
            }
            default{
                $definitions = Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).tepp.EntryProperties"
                if(-not $definitions.containskey($entityName)){return}
                # Write-PSFMessage "$entityName>$wordToComplete"
                if ($wordToComplete -match "([^.]+)\..*"){
                    $subPropName = $wordToComplete -replace "([^.]+)\..*",'$1'
                    if ($definitions.containskey("$entityName.$subPropName")){
                        # Write-PSFMessage "$entityName>>$subPropName"
                        # Write-PSFMessage "`$definitions.`"$entityName.$subPropName`""
                        return $definitions."$entityName.$subPropName" #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
                    }
                }
                return $definitions.$entityName #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
            }
        }

    }
    catch {
        return "Error"
    }
}
