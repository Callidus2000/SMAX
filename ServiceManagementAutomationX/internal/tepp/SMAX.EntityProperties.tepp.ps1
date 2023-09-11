Register-PSFTeppScriptblock -Name "SMAX.EntityProperties" -ScriptBlock {
    try {
        $connection=Get-SMAXLastConnection
        $entityName = $fakeBoundParameter.EntityName
        if ([string]::IsNullOrEmpty($entityName)){return}

        $definitions = Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).tepp.EntryProperties"
        if(-not $definitions.containskey($entityName)){return}
        # write-host $fakeBoundParameter.EntityName
        return $definitions.$entityName #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
        # Write-PSFMessage -level host "Hubba"
        # if ($Global:ENTITYDESCRIPTION) {
        #     return $Global:ENTITYDESCRIPTION.name
        # }
    }
    catch {
        return "Error"
    }
}
