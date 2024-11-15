function Initialize-SMAXEntityModel {
    <#
    .SYNOPSIS
        Initializes the Micro Focus SMAX entity model for improved performance.

    .DESCRIPTION
        The Initialize-SMAXEntityModel function initializes the entity model for the
        Micro Focus SMAX API. It retrieves and processes entity definitions, properties,
        associations, and translations from the SMAX server's metadata. The resulting
        data is stored in the PSFramework configuration for improved performance and
        ease of use when working with SMAX entities.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it
        will use the last saved connection obtained using the Get-SMAXLastConnection
        function.

    .PARAMETER EnableException
        Indicates whether to enable exception handling. If set to $true (default),
        the function will throw exceptions on API errors. If set to $false, it will
        return error information as part of the result.

    .PARAMETER Persist
        If specified, the configuration settings for the SMAX entity model will be
        persisted in the user's default configuration scope.

    .PARAMETER ExportDevJson
        If specified, the configuration settings for the SMAX entity model will be
        exported to JSON files for development and debugging purposes.

    .EXAMPLE
        Initialize-SMAXEntityModel -Connection $MyConnection -Persist -ExportDevJson

        Description:
        Initializes the SMAX entity model using a specific SMAX connection, persists
        the configuration settings, and exports them to JSON files for development.

    .NOTES
        Date:   September 28, 2023
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [switch]$Persist,
        [switch]$ExportDevJson
    )

    $prefix = Get-SMAXConfPrefix -Connection $Connection
    $apiCallParameter = @{
        EnableException = $EnableException
        Connection      = $Connection
        LoggingAction   = "Get-SMAXMetaEntityDescription"
        # LoggingActionValues = @($addressList.count, $explicitADOM)
        method          = "GET"
        Path            = "/metadata/ui/entity-descriptors"
    }
    $result = Invoke-SMAXAPI @apiCallParameter
    $fullEntityDescription = $result.entity_descriptors | Where-Object domain -NotMatch 'sample'
    Set-PSFConfig -FullName "$prefix.fullEntityDescription" -Value $fullEntityDescription -AllowDelete -Description "The complete entity metadata for the given server and tennant."
    Set-PSFConfig -FullName "$prefix.possibleEntityNames" -Value $fullEntityDescription.Name -AllowDelete -Description "The complete list of entity names"
    $translation = Get-SMAXMetaTranslation -Connection $Connection
    Set-PSFConfig -FullName "$prefix.translation" -Value $translation -AllowDelete -Description "The translation dictionary"
    $parsedDefinitions = @{}
    foreach ($entity in $fullEntityDescription) {
        $name = $entity.name
        $newDefinition = @{}
        $parsedDefinitions.$name = $newDefinition
        $newDefinition.name = $name
        $newDefinition.locName = $translation.($entity.localized_label_key)
        $propertyList = New-Object System.Collections.ArrayList
        foreach ($property in $entity.property_descriptors) {
            $newProp = $property | ConvertTo-PSFHashtable -Include name, domain, required, readonly, logical_type
            $newProp.locName = $translation.($property.localized_label_key)
            switch ($property.logical_type) {
                'BOOLEAN' {}
                'COMPLEX_TYPE' {}
                'DATE_TIME' {}
                'DOUBLE' {}
                'ENUM_SET' {}
                'INTEGER' {}
                'LARGE_TEXT' {}
                'MEDIUM_TEXT' {}
                'RICH_TEXT' {}
                'SMALL_TEXT' {}
                'ENUM' {
                    $newProp.enumName = $property.enumeration_descriptor.name
                    $newProp.locEnumName = $translation.($property.enumeration_descriptor.localized_label_key)
                    $possibleEnumValues = @{}
                    foreach ($enum in $property.enumeration_descriptor.values) {
                        $possibleEnumValues."$($enum.name)" = $translation.($enum.localized_label_key)
                    }
                    $newProp.possibleValues = [PSCustomObject]$possibleEnumValues
                }
                'ENTITY_LINK' {
                    $newProp.linkEntityName = $property.relation_descriptor.name
                    $newProp.locLinkEntityName = $translation.($property.relation_descriptor.localized_label_key)
                    $newProp.cardinality = $property.relation_descriptor.cardinality
                    $newProp.remoteEntityName = $property.relation_descriptor.second_endpoint_entity_name
                }
            }
            $propertyList.Add([PSCustomObject]$newProp) | Out-Null
        }
        $newDefinition.properties = $propertyList.ToArray()
        $associationsList = New-Object System.Collections.ArrayList
        foreach ($relation in $entity.relation_descriptors) {
            $newRelation = $relation | ConvertTo-PSFHashtable -Include name, domain, cardinality
            $newRelation.locName = $translation.($relation.localized_label_key)
            $newRelation.linkEntityName = $relation.second_endpoint_entity_name
            $associationsList.Add([PSCustomObject]$newRelation) | Out-Null
        }
        $newDefinition.associations = $associationsList.ToArray()
    }
    Set-PSFConfig -FullName "$prefix.entityDefinition" -Value $parsedDefinitions -AllowDelete -Description "The parsed entity definitions"
    $teppEntryNames = @()
    $teppEntryProperties = @{}
    $teppAssociations=@{}
    $teppAssociationProperties=@{}
    foreach ($name in $parsedDefinitions.Keys) {
        $teppEntryNames += @{Text = $name; ToolTip = $parsedDefinitions.$name.locname }
        $teppEntryProperties.$name = @()
        foreach ($property in $parsedDefinitions.$name.properties) {
            $propName = $property.name
            $locName = $property.locname
            $teppEntryProperties.$name += @{Text = $propName; ToolTip = $locName }
            if ($property.logical_type -eq "ENTITY_LINK") {
                $linkEntityName = $property.remoteEntityName
                # Write-Host "Ergänze Props von $propName des Typs $linkEntityName"
                $subProperties = @()
                foreach ($subProperty in $parsedDefinitions.$linkEntityName.properties) {
                    $subProperties += @{Text = "$($propName).$($subProperty.name)"; ToolTip = $subProperty.locName }
                    # Write-PSFMessage "`$teppEntryProperties.`"$name.$propName`"+=$(@{Text = "$($propName).$($subProperty.name)"; ToolTip = $subProperty.locName }|ConvertTo-Json -WarningAction SilentlyContinue -Compress)"
                }
                $teppEntryProperties."$name.$propName" = $subProperties
            }
        }
        # Save the Associations
        $teppAssociations.$name=@()
        Write-PSFMessage "Query Association für $name"
        foreach ($association in $parsedDefinitions.$name.associations) {
            $teppAssociations.$name += @{Text = $association.name; ToolTip = $association.locName }
            $assPropList = New-Object System.Collections.ArrayList
            $linkEntityName = $association.linkEntityName
            # Write-PSFMessage -Level Host "`$parsedDefinitions.$linkEntityName.properties"
            foreach ($subProperty in $parsedDefinitions.$linkEntityName.properties) {
                $assPropList.Add(@{Text = "$($subProperty.name)"; ToolTip = $subProperty.locName })|Out-Null
            }
            $teppAssociationProperties."$name.$($association.name)" = $assPropList.ToArray()
        }
    }
    Set-PSFConfig -FullName "$prefix.tepp.EntryNames" -Value $teppEntryNames -AllowDelete -Description "The suggestions for Entrynames"
    Set-PSFConfig -FullName "$prefix.tepp.EntryProperties" -Value $teppEntryProperties -AllowDelete -Description "The suggestions for Entry Property Names"
    Set-PSFConfig -FullName "$prefix.tepp.EntityAssociations" -Value $teppAssociations -AllowDelete -Description "The suggestions for Entry Association Names"
    Set-PSFConfig -FullName "$prefix.tepp.EntityAssociationProperties" -Value $teppAssociationProperties -AllowDelete -Description "The suggestions for Entry Association Property Names"
    if ($Persist) {
        $configs=Get-PSFConfig | Where-Object fullname -like "$prefix*"
        Write-PSFMessage "Register configs: $($configs.FullName -join ',')"
        Register-PSFConfig -config $configs $_ -Scope UserDefault
    }
    if ($ExportDevJson) {
        $cfgFullNames=Get-PSFConfig | Where-Object fullname -like "$prefix*" | Select-Object -ExpandProperty FullName
        foreach($cfgName in $cfgFullNames){
            $filename = Join-Path $moduleRoot "en-us" (($cfgName -replace "SMAX.") + '.json')
            Write-PSFMessage -Level Host "Exporting PSFConfig $cfgName to $filename"
            Get-PSFConfigValue -FullName $cfgName|ConvertTo-Json -WarningAction SilentlyContinue -Depth 10 |Out-File -FilePath $filename -Force
        }
    }
}