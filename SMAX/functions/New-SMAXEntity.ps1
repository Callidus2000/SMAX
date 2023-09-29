function New-SMAXEntity {
    <#
    .SYNOPSIS
        Creates an empty entity object for Micro Focus SMAX.

    .DESCRIPTION
        The New-SMAXEntity function is used to create an empty entity object for use
        with Micro Focus SMAX. It generates an object with the specified entity type
        and includes all required properties. You can also select optional properties
        to include in the object.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it
        will use the last saved connection obtained using the Get-SMAXLastConnection
        function.

    .PARAMETER EntityType
        Specifies the name of the entity type for which the empty object is created.

    .PARAMETER Properties
        Specifies an array of property names to include in the empty entity object.

    .PARAMETER ReturnMode
        Specifies the return mode for the generated object. Valid values are HashTable,
        Definition, and DefinitionCopyToClipboard. Default is HashTable.

    .EXAMPLE
        $emptyEntity = New-SMAXEntity -EntityType "Incident" -Properties "Title", "Description"

        Description:
        Creates an empty incident entity object with the specified properties.

    .EXAMPLE
        $emptyEntityDef = New-SMAXEntity -EntityType "Change" -Properties "Title", "ScheduledStartDate" -ReturnMode "Definition"

        Description:
        Generates a definition of an empty change entity object with specific properties.

    .NOTES
        Date:   September 28, 2023
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityProperties")]
        [string[]]$Properties,
       	[ValidateSet('HashTable', 'Definition', 'DefinitionCopyToClipboard')]
        [string]$ReturnMode = "HashTable"
    )
    Write-PSFMessage "Creating empty entity of type $EntityType with all required properties"
    $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"
    if (-not $definitions.containskey($EntityType)) {
        Write-PSFMessage -Level Critical "Entitytype $EntityType not defined"
        return
    }
    $allPossibleProperties = $definitions.$EntityType.properties
    $mandatoryProperties = $allPossibleProperties | Where-Object required -eq $true
    $optionalProperties = $allPossibleProperties | Where-Object required -eq $false
    $nonExistingProperties = $Properties | Where-Object { ($_ -notin $allPossibleProperties.name) }
    $alreadyMandatoryProperties = $Properties | Where-Object { ($_ -in $mandatoryProperties.name) }
    if (-not [string]::IsNullOrEmpty($alreadyMandatoryProperties)) {
        Write-PSFMessage -Level Warning "The following properties are mandatory and therefor already included: $($alreadyMandatoryProperties -join ',')"
    }
    if (-not [string]::IsNullOrEmpty($nonExistingProperties)) {
        Write-PSFMessage -Level Warning "The following properties do not exist for Entities of type $($EntityType): $($nonExistingProperties -join ',')"
    }
    $propertiesToInclude = ($mandatoryProperties + ($optionalProperties | Where-Object name -in $Properties)) | Sort-Object -Property Name
    switch -Regex ($ReturnMode){
        '^HashTable$'{
            $result=@{}
            foreach ($key in $propertiesToInclude.name) {
                $result.$key=""
            }
        }
        'Definition'{
            $padLeft = ($propertiesToInclude.name | Measure-Object -Maximum -Property Length).Maximum
            $sb = [System.Text.StringBuilder]::new()
            [void]$sb.AppendLine( "`$$EntityType=@{" )
            [void]$sb.AppendFormat( "    # {0,$(-$padLeft+2)} = `"{1}`"   # Uncomment if converted to [PSCustomObject] later", @("PSTypeName", "SMAX.$EntityType") )
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