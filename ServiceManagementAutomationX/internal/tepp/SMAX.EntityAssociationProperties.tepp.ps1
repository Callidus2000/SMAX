Register-PSFTeppScriptblock -Name "SMAX.EntityAssociationProperties" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)){
            $connection = Get-SMAXLastConnection -EnableException $false
        }else{
            $connection = $fakeBoundParameter.Connection
        }
        $entityName = $fakeBoundParameter.EntityName
        $associationName = $fakeBoundParameter.Association
        if ([string]::IsNullOrEmpty($entityName)) { return }
        if ([string]::IsNullOrEmpty($associationName)) { return }

        $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).tepp.EntityAssociationProperties"
        if (-not $definitions.containskey("$entityName.$associationName")) { return }
        return $definitions."$entityName.$associationName"
    }
    catch {
        return "Error"
    }
}
