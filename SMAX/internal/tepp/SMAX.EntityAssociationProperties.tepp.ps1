Register-PSFTeppScriptblock -Name "SMAX.EntityAssociationProperties" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)){
            $connection = Get-SMAXLastConnection -EnableException $false
        }else{
            $connection = $fakeBoundParameter.Connection
        }
        $EntityType = $fakeBoundParameter.EntityType
        $associationName = $fakeBoundParameter.Association
        if ([string]::IsNullOrEmpty($EntityType)) { return }
        if ([string]::IsNullOrEmpty($associationName)) { return }

        $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).tepp.EntityAssociationProperties"
        if (-not $definitions.containskey("$EntityType.$associationName")) { return }
        return $definitions."$EntityType.$associationName"
    }
    catch {
        return "Error"
    }
}
