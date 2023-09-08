Register-PSFTeppScriptblock -Name "SMAX.EntityNames" -ScriptBlock {
    try {
        $connection=Get-SMAXLastConnection
        return Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).possibleEntityNames"
        # Write-PSFMessage -level host "Hubba"
        # if ($Global:ENTITYDESCRIPTION) {
        #     return $Global:ENTITYDESCRIPTION.name
        # }
    }
    catch {
        return "Error"
    }
}
