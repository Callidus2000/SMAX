﻿function Initialize-SMAXEntityModel {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [switch]$Persist
    )

    $prefix = $Connection.psfConfPrefix
    $apiCallParameter = @{
        EnableException = $EnableException
        Connection      = $Connection
        LoggingAction   = "Get-SMAXEntityDescription"
        # LoggingActionValues = @($addressList.count, $explicitADOM)
        method          = "GET"
        Path            = "/metadata/ui/entity-descriptors"
    }
    $result = Invoke-SMAXAPI @apiCallParameter
    $fullEntityDescription = $result.entity_descriptors | Where-Object domain -NotMatch 'sample'
    Set-PSFConfig -FullName "$prefix.fullEntityDescription" -Value $fullEntityDescription -AllowDelete -Description "The complete entity metadata for the given server and tennant."
    Set-PSFConfig -FullName "$prefix.possibleEntityNames" -Value $fullEntityDescription.Name -AllowDelete -Description "The complete list of entity names"
    $translation=Get-SMAXTranslation -Connection $Connection
    Set-PSFConfig -FullName "$prefix.translation" -Value $translation -AllowDelete -Description "The translation dictionary"
    $parsedDefinitions=@{}
    foreach($entity in $fullEntityDescription){
        $name=$entity.name
        $newDefinition=@{}
        $parsedDefinitions.$name = $newDefinition
        $newDefinition.name=$name
        $newDefinition.locName = $translation.($entity.localized_label_key)
        $propertyList = New-Object System.Collections.ArrayList
        foreach ($property in $entity.property_descriptors) {
            $newProp = $property|ConvertTo-PSFHashtable -Include name,domain,required,readonly,logical_type
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
                    $possibleEnumValues=@{}
                    foreach ($enum in $property.enumeration_descriptor.values){
                        $possibleEnumValues."$($enum.name)" = $translation.($enum.localized_label_key)
                    }
                    $newProp.possibleValues = [PSCustomObject]$possibleEnumValues
                }
                'ENTITY_LINK' {
                    $newProp.linkEntityName = $property.relation_descriptor.name
                    $newProp.locLinkEntityName = $translation.($property.relation_descriptor.localized_label_key)
                    $newProp.cardinality = $property.relation_descriptor.cardinality
                }
            }
            $propertyList.Add([PSCustomObject]$newProp)|Out-Null
        }
        $newDefinition.properties = $propertyList.ToArray()
    }
    Set-PSFConfig -FullName "$prefix.entityDefinition" -Value $parsedDefinitions -AllowDelete -Description "The parsed entity definitions"

}