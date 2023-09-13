function New-SMAXEntity {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityProperties")]
        [string[]]$Properties,
       	[ValidateSet('HashTable', 'Definition', 'DefinitionCopyToClipboard')]
        [string]$ReturnMode = "HashTable"
    )
    Write-PSFMessage "Creating empty entity of type $EntityName with all required properties"
    $definitions = Get-PSFConfigValue -FullName "$($connection.psfConfPrefix).entityDefinition"
    if (-not $definitions.containskey($entityName)) {
        Write-PSFMessage -Level Critical "Entitytype $EntityName not defined"
        return
    }
    $allPossibleProperties = $definitions.$EntityName.properties
    $mandatoryProperties = $allPossibleProperties | Where-Object required -eq $true
    $optionalProperties = $allPossibleProperties | Where-Object required -eq $false
    $nonExistingProperties = $Properties | Where-Object { ($_ -notin $allPossibleProperties.name) }
    $alreadyMandatoryProperties = $Properties | Where-Object { ($_ -in $mandatoryProperties.name) }
    if (-not [string]::IsNullOrEmpty($alreadyMandatoryProperties)) {
        Write-PSFMessage -Level Warning "The following properties are mandatory and therefor already included: $($alreadyMandatoryProperties -join ',')"
    }
    if (-not [string]::IsNullOrEmpty($nonExistingProperties)) {
        Write-PSFMessage -Level Warning "The following properties do not exist for Entities of type $($EntityName): $($nonExistingProperties -join ',')"
    }
    $propertiesToInclude = ($mandatoryProperties + ($optionalProperties | Where-Object name -in $Properties)) | Sort-Object -Property Name
    $padLeft=($propertiesToInclude.name | Measure-Object -Maximum -Property Length).Maximum
    # $padLeft=($propertiesToInclude.lname | Measure-Object -Maximum -Property Length).Maximum +1
    switch -Regex ($ReturnMode){
        '^HashTable$'{
            $result=@{}
            foreach ($key in $propertiesToInclude.name) {
                $result.$key=""
            }
        }
        'Definition'{
            $sb = [System.Text.StringBuilder]::new()
            [void]$sb.AppendLine( "`$$EntityName=@{" )
            [void]$sb.AppendFormat( "    # {0,$(-$padLeft+2)} = `"{1}`"   # Uncomment if converted to [PSCustomObject] later", @("PSTypeName", "SMAX.$EntityName") )
            [void]$sb.AppendLine(  )
            foreach ($prop in $propertiesToInclude) {
                [void]$sb.AppendFormat( "    {0,-$padLeft} = `"`"   # {1}", @($prop.name,$prop.locname) )
                if ($prop.required -eq $true) { [void]$sb.Append(', mandatory')}
                [void]$sb.AppendLine(  )
            }
            [void]$sb.AppendLine( "}" )
            $result=$sb.ToString()
            Write-PSFMessage "New Definition=`r$result"
            if ($_ -match 'CopyToClipboard'){
                Write-PSFMessage -Level Host "Definition copied to clipboard"
                $result|Set-Clipboard
            }
        }
    }

    return $result

}