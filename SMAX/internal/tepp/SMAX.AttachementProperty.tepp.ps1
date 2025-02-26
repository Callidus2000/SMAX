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
        $associationData = $definitions.$EntityType.associations | Select-Object name, locname, cardinality, @{name = 'details'; expression = $detailsScript } | Sort-Object -Property locname
        switch ($Mode) {
            'String' {
                $sb = New-Object System.Text.StringBuilder
                [void]$sb.AppendFormat("Entity-Type {0}", $EntityType).AppendLine()
                [void]$sb.AppendLine("Properties:")
                [void]$sb.Append(($propertyData | Format-Table -Wrap | Out-String))
                [void]$sb.AppendLine("Associations:")
                [void]$sb.Append(($associationData | Format-Table -Wrap | Out-String))

                return $sb.ToString()
            }
            'Properties' { return $propertyData }
            'Associations' { return $associationData }
        }
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
