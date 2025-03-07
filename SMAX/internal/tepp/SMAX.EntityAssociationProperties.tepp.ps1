<#
.SYNOPSIS
Registers a PSFramework TEPP scriptblock for SMAX entity association properties.

.DESCRIPTION
This function registers a TEPP scriptblock named "SMAX.EntityAssociationProperties".
It retrieves the connection information and fetches entity association properties
based on the provided entity type and association name.

.PARAMETER Name
The name of the TEPP scriptblock to register.

.PARAMETER ScriptBlock
The scriptblock to register.

.EXAMPLE
Register-PSFTeppScriptblock -Name "SMAX.EntityAssociationProperties" -ScriptBlock { ... }

#>
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
