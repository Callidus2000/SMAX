function Resolve-SMAXEntityInput {
    <#
    .SYNOPSIS
        Resolves generic entity input into SMAX-compatible properties.

    .DESCRIPTION
        Resolves property names against SMAX metadata, lookup values, and ENUM values.
        Input can be provided as a JSON object string, PSCustomObject, or dictionary.
        UserOptions values support complete inline lookup tokens in the format
        {{lookup:EntityType|Filter}}.

    .PARAMETER InputObject
        A JSON object string, PSCustomObject, or dictionary containing entity properties.
        This parameter accepts pipeline input.

    .PARAMETER EntityType
        The SMAX entity type whose metadata is used to resolve the input properties.

    .PARAMETER Connection
        The connection used to read metadata and resolve SMAX entity lookups.

    .EXAMPLE
        $input = '{"CurrentAssignment":"servicedesk"}'
        Resolve-SMAXEntityInput -InputObject $input -EntityType Request

        Description:
        Resolves the CurrentAssignment ENUM value to its canonical SMAX value.

    .EXAMPLE
        @{ 'lookup.AssignedToGroup' = "Name='Operations'" } |
            Resolve-SMAXEntityInput -EntityType Request -Connection $connection

        Description:
        Resolves an entity-link lookup from a hashtable received through the pipeline.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$InputObject,

        [Parameter(Mandatory = $true)]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute('SMAX.EntityTypes')]
        [string]$EntityType,

        [Parameter(Mandatory = $false)]
        [object]$Connection = (Get-SMAXLastConnection)
    )

    process {
        if ($InputObject -is [string]) {
            if ([string]::IsNullOrWhiteSpace($InputObject)) {
                throw 'InputObject must not be an empty JSON string.'
            }

            try {
                $inputProperties = $InputObject | ConvertFrom-Json -ErrorAction Stop
            }
            catch {
                throw 'InputObject must contain valid JSON.'
            }
        }
        elseif ($InputObject -is [System.Collections.IDictionary] -or $InputObject -is [pscustomobject]) {
            $inputProperties = $InputObject
        }
        else {
            throw "InputObject must be a JSON string, PSCustomObject, or dictionary. Received '$($InputObject.GetType().FullName)'."
        }

        if ($inputProperties -is [System.Collections.IList] -or $inputProperties -isnot [System.Collections.IDictionary] -and $inputProperties -isnot [pscustomobject]) {
            throw 'InputObject must represent a JSON object, PSCustomObject, or dictionary.'
        }

        $description = Get-SMAXEntityDescription -Connection $Connection -EntityType $EntityType -Mode PropertiesAsHashtable
        $smaxBody = [ordered]@{}
        $properties = if ($inputProperties -is [System.Collections.IDictionary]) {
            $inputProperties.GetEnumerator() | ForEach-Object {
                [pscustomobject]@{
                    Name  = [string]$_.Key
                    Value = $_.Value
                }
            }
        }
        else {
            $inputProperties.PSObject.Properties
        }

        $canonicalAttributeNames = @{}
        foreach ($inputProperty in $properties) {
            $inputKey = [string]$inputProperty.Name
            $isLookup = $inputKey.StartsWith('lookup.', [System.StringComparison]::OrdinalIgnoreCase)
            $attributeName = if ($isLookup) { $inputKey.Substring('lookup.'.Length) } else { $inputKey }
            $attributeDescription = $description.$attributeName

            if ($null -eq $attributeDescription) {
                throw "Property '$attributeName' is not available for entity type '$EntityType'."
            }

            $canonicalAttributeName = [string]$attributeDescription.name
            if ($canonicalAttributeNames.ContainsKey($canonicalAttributeName)) {
                throw "Property '$canonicalAttributeName' is specified more than once."
            }

            $canonicalAttributeNames[$canonicalAttributeName] = $true
        }

        foreach ($inputProperty in $properties) {
            $inputKey = [string]$inputProperty.Name
            $isLookup = $inputKey.StartsWith('lookup.', [System.StringComparison]::OrdinalIgnoreCase)
            $attributeName = if ($isLookup) { $inputKey.Substring('lookup.'.Length) } else { $inputKey }
            $attributeDescription = $description.$attributeName

            if ($null -eq $attributeDescription) {
                throw "Property '$attributeName' is not available for entity type '$EntityType'."
            }

            $canonicalAttributeName = [string]$attributeDescription.name
            if ($isLookup) {
                if ($attributeDescription.logical_type -ne 'ENTITY_LINK') {
                    throw "Lookup '$inputKey' refers to '$canonicalAttributeName', which is not an ENTITY_LINK."
                }

                $remoteType = [string]$attributeDescription.remoteType
                if ([string]::IsNullOrWhiteSpace($remoteType)) {
                    throw "No remoteType is available for ENTITY_LINK '$canonicalAttributeName'."
                }

                $filter = [string]$inputProperty.Value
                if ([string]::IsNullOrWhiteSpace($filter)) {
                    throw "Lookup '$inputKey' requires an SMAX filter."
                }

                $linkedEntity = @(Get-SMAXEntity -Connection $Connection -Properties Id -EntityType $remoteType -Filter $filter)
                if ($linkedEntity.Count -eq 0) {
                    throw "Lookup '$inputKey' did not find a '$remoteType' entity for filter '$filter'."
                }
                if ($linkedEntity.Count -gt 1) {
                    throw "Lookup '$inputKey' found multiple '$remoteType' entities for filter '$filter'."
                }

                $smaxBody[$canonicalAttributeName] = $linkedEntity[0].Id
                continue
            }

            $attributeValue = $inputProperty.Value
            if ($attributeDescription.logical_type -eq 'ENUM') {
                $validEnumValues = @($attributeDescription.possibleValues.PSObject.Properties.Name)
                if ($validEnumValues.Count -eq 0) {
                    throw "No valid values are available in SMAX metadata for ENUM '$canonicalAttributeName'."
                }
                if ($attributeValue -isnot [string]) {
                    throw "Value '$attributeValue' for ENUM '$canonicalAttributeName' must be a string."
                }

                $matchingEnumValues = @($validEnumValues | Where-Object { $_ -ieq $attributeValue })
                if ($matchingEnumValues.Count -ne 1) {
                    $validValuesText = $validEnumValues -join "', '"
                    throw "Value '$attributeValue' is invalid for ENUM '$canonicalAttributeName'. Valid values: '$validValuesText'."
                }

                $attributeValue = [string]$matchingEnumValues[0]
                if ($inputProperty.Value -cne $attributeValue) {
                    Write-PSFMessage -Level Verbose -Message "Resolve-SMAXEntityInput: ENUM '$canonicalAttributeName' was normalized from '$($inputProperty.Value)' to '$attributeValue'."
                }
            }

            if ($canonicalAttributeName -ceq 'UserOptions') {
                if ($attributeValue -isnot [string] -or [string]::IsNullOrWhiteSpace($attributeValue)) {
                    throw "Property '$canonicalAttributeName' must contain a JSON string."
                }

                try {
                    $userOptions = $attributeValue | ConvertFrom-Json -ErrorAction Stop
                }
                catch {
                    throw "Property '$canonicalAttributeName' does not contain valid JSON."
                }

                if ($userOptions -is [System.Collections.IList] -or $userOptions -isnot [pscustomobject]) {
                    throw "Property '$canonicalAttributeName' must contain a JSON object."
                }

                $valuesToCheck = [System.Collections.Stack]::new()
                $valuesToCheck.Push(@{
                        Value  = $userOptions
                        Parent = $null
                        Key    = $null
                        Path   = $canonicalAttributeName
                    })

                while ($valuesToCheck.Count -gt 0) {
                    $currentValue = $valuesToCheck.Pop()

                    if ($currentValue.Value -is [System.Collections.IDictionary]) {
                        foreach ($key in $currentValue.Value.Keys) {
                            $valuesToCheck.Push(@{
                                    Value  = $currentValue.Value[$key]
                                    Parent = $currentValue.Value
                                    Key    = $key
                                    Path   = "$($currentValue.Path).$key"
                                })
                        }
                        continue
                    }

                    if ($currentValue.Value -is [pscustomobject]) {
                        foreach ($property in $currentValue.Value.PSObject.Properties) {
                            $valuesToCheck.Push(@{
                                    Value  = $property.Value
                                    Parent = $currentValue.Value
                                    Key    = $property.Name
                                    Path   = "$($currentValue.Path).$($property.Name)"
                                })
                        }
                        continue
                    }

                    if ($currentValue.Value -is [System.Collections.IList] -and $currentValue.Value -isnot [string]) {
                        for ($index = 0; $index -lt $currentValue.Value.Count; $index++) {
                            $valuesToCheck.Push(@{
                                    Value  = $currentValue.Value[$index]
                                    Parent = $currentValue.Value
                                    Key    = $index
                                    Path   = "$($currentValue.Path)[$index]"
                                })
                        }
                        continue
                    }

                    if ($currentValue.Value -isnot [string]) {
                        continue
                    }

                    $lookupToken = [regex]::Match($currentValue.Value, '^\{\{lookup:(?<EntityType>[^|{}]+)\|(?<Filter>.+)\}\}$')
                    if (-not $lookupToken.Success) {
                        continue
                    }

                    $lookupEntityType = $lookupToken.Groups['EntityType'].Value.Trim()
                    $lookupFilter = $lookupToken.Groups['Filter'].Value.Trim()
                    if ([string]::IsNullOrWhiteSpace($lookupEntityType) -or [string]::IsNullOrWhiteSpace($lookupFilter)) {
                        throw "Lookup token at '$($currentValue.Path)' requires EntityType and Filter: {{lookup:EntityType|Filter}}."
                    }

                    $linkedEntity = @(Get-SMAXEntity -Connection $Connection -Properties Id -EntityType $lookupEntityType -Filter $lookupFilter)
                    if ($linkedEntity.Count -eq 0) {
                        throw "Lookup token at '$($currentValue.Path)' did not find a '$lookupEntityType' entity for filter '$lookupFilter'."
                    }
                    if ($linkedEntity.Count -gt 1) {
                        throw "Lookup token at '$($currentValue.Path)' found multiple '$lookupEntityType' entities for filter '$lookupFilter'."
                    }

                    if ($currentValue.Parent -is [System.Collections.IDictionary] -or $currentValue.Parent -is [System.Collections.IList]) {
                        $currentValue.Parent[$currentValue.Key] = $linkedEntity[0].Id
                    }
                    else {
                        $currentValue.Parent.PSObject.Properties[$currentValue.Key].Value = $linkedEntity[0].Id
                    }
                    Write-PSFMessage -Level Verbose -Message "Resolve-SMAXEntityInput: UserOptions lookup at '$($currentValue.Path)' was resolved to Id '$($linkedEntity[0].Id)'."
                }

                $attributeValue = $userOptions | ConvertTo-Json -Depth 100 -Compress
            }

            $smaxBody[$canonicalAttributeName] = $attributeValue
        }

        $smaxBody
    }
}