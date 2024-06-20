function Get-SMAXEntityDescription {
    <#
    .SYNOPSIS
        Retrieves entity descriptions from the Micro Focus SMAX API.

    .DESCRIPTION
        The Get-SMAXEntityDescription function retrieves descriptions of an entity,
        including its properties and associations, from the Micro Focus SMAX API.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it
        will use the last saved connection obtained using the Get-SMAXLastConnection
        function.

    .PARAMETER EnableException
        Indicates whether to enable exception handling. If set to $true (default),
        the function will throw exceptions on API errors. If set to $false, it will
        return error information as part of the result.

    .PARAMETER EnablePaging
        Enables paging for large result sets. By default, paging is enabled.

    .PARAMETER EntityType
        Specifies the name of the entity for which descriptions are retrieved. This
        parameter supports tab completion using SMAX.EntityTypes.

    .PARAMETER Mode
        What should the function return?
        'String' - A string representation
        'Properties' - All properties of the entitytype
        'Associations' - All association of the entitytype


    .EXAMPLE
        Get-SMAXEntityDescription -EntityType "Incident"

        Description:
        Retrieves descriptions of the "Incident" entity, including its properties and
        associations.

    .EXAMPLE
        Get-SMAXEntityDescription -EntityType "Change"

        Description:
        Retrieves descriptions of the "Change" entity, including its properties and
        associations.

    .NOTES
        Date:   September 28, 2023
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "default")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        [ValidateSet('String', 'Properties', 'Associations')]
        [string]$Mode = 'String'
    )
    $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"

    $detailsScript = {
        $property = $_
        if ($property.logical_type -eq 'ENTITY_LINK') {
            "remoteType: $($property.remoteEntityName)"
        }
        elseif ($property.cardinality) {
            "remoteType: $($property.linkEntityName)"
        }
        elseif ($property.logical_type -eq 'ENUM') {
            "possible values: $($property.possibleValues|ConvertTo-Json -Compress)"
        }
    }
    $propertyData = $definitions.$EntityType.properties | Select-Object name, locname, logical_type, @{name = 'details'; expression = $detailsScript } | Sort-Object -Property locname
    $associationData = $definitions.$EntityType.associations | Select-Object name, locname, cardinality, @{name = 'details'; expression = $detailsScript } | Sort-Object -Property locname
    switch ($Mode) {
        'String' {
            $sb = new System.Text.StringBuilder
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

    # return $result.properties
}