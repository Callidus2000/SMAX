Register-PSFTeppScriptblock -Name "SMAX.EntityAssociationProperties" -ScriptBlock {
    try {
        $connection = Get-SMAXLastConnection
        $entityName = $fakeBoundParameter.EntityName
        $associationName = $fakeBoundParameter.Association
        if ([string]::IsNullOrEmpty($entityName)) { return }
        if ([string]::IsNullOrEmpty($associationName)) { return }

        $definitions = Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).tepp.EntityAssociationProperties"
        if (-not $definitions.containskey("$entityName.$associationName")) { return }
        return $definitions."$entityName.$associationName"
    }
    catch {
        return "Error"
    }
}
