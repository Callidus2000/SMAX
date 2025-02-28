<#
.SYNOPSIS
Registers a PSFramework Tab Expansion Plus Plus (TEPP) script block for
SMAX attachment properties.

.DESCRIPTION
The TEPP script block retrieves all properties of type 'COMPLEX_TYPE' for
a given entity type, as these are suitable for storing attachment
information. The TEPP is used by the function Add-SMAXAttachement.
#>
Register-PSFTeppScriptblock -Name "SMAX.AttachementProperty" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)) {
            $connection = Get-SMAXLastConnection -EnableException $false
        }
        else {
            $connection = $fakeBoundParameter.Connection
        }
        $EntityType = $fakeBoundParameter.EntityType
        if ([string]::IsNullOrEmpty($EntityType)){return}

        $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"

        return $definitions.$EntityType.properties | Where-Object logical_type -eq 'COMPLEX_TYPE' | Select-psfObject "name as text", "locname as ToolTip" | Sort-Object -Property ToolTip
    }
    catch {
        return "Error"
    }
}
