Register-PSFTeppScriptblock -Name "SMAX.EntityNames" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)) {
            $connection = Get-SMAXLastConnection
        }
        else {
            $connection = $fakeBoundParameter.Connection
        }
        return Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).tepp.EntryNames" #| Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName } }
        # Write-PSFMessage -level host "Hubba"
        # if ($Global:ENTITYDESCRIPTION) {
        #     return $Global:ENTITYDESCRIPTION.name
        # }
    }
    catch {
        return "Error"
    }
}
