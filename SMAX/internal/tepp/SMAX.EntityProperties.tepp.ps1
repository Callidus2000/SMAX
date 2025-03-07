<#
.SYNOPSIS
Registers a PSFramework TEPP scriptblock for SMAX entity properties.

.DESCRIPTION
This function registers a TEPP scriptblock named "SMAX.EntityProperties". It
retrieves the connection information and fetches entity properties based on
the provided entity type and command name.

.PARAMETER Name
The name of the TEPP scriptblock to register.

.PARAMETER ScriptBlock
The scriptblock to register.

.EXAMPLE
Register-PSFTeppScriptblock -Name "SMAX.EntityProperties" -ScriptBlock { ... }

#>
Register-PSFTeppScriptblock -Name "SMAX.EntityProperties" -ScriptBlock {
    try {
        if ([string]::IsNullOrEmpty($fakeBoundParameter.Connection)) {
            $connection = Get-SMAXLastConnection -EnableException $false
        }
        else {
            $connection = $fakeBoundParameter.Connection
        }
        $EntityType = $fakeBoundParameter.EntityType
        if ([string]::IsNullOrEmpty($EntityType)){return}
        switch ($commandName){
            'New-SMAXEntity' {
                $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"
                return $definitions.$EntityType.properties | where-object required -eq $false | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
            }
            default{
                $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).tepp.EntryProperties"
                if(-not $definitions.containskey($EntityType)){return}
                # Write-PSFMessage "$EntityType>$wordToComplete"
                if ($wordToComplete -match "([^.]+)\..*"){
                    $subPropName = $wordToComplete -replace "([^.]+)\..*",'$1'
                    if ($definitions.containskey("$EntityType.$subPropName")){
                        # Write-PSFMessage "$EntityType>>$subPropName"
                        # Write-PSFMessage "`$definitions.`"$EntityType.$subPropName`""
                        return $definitions."$EntityType.$subPropName" #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
                    }
                }
                return $definitions.$EntityType #.properties | Select-Object @{name = "Text"; expression = { $_.name } }, @{name = "ToolTip"; expression = { $_.locName}}
            }
        }

    }
    catch {
        return "Error"
    }
}
