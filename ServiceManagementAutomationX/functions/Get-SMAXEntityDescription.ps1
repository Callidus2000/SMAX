function Get-SMAXEntityDescription {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "default")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName
        # [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "default")]
        # [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityProperties")]
        # [string[]]$Properties
    )
    $sb=new System.Text.StringBuilder
    $definitions = Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).entityDefinition"

    $detailsScript = {
        $property=$_
        if ($property.logical_type -eq 'ENTITY_LINK') {
              "remoteType: $($property.remoteEntityName)"
            }elseif($property.cardinality){
            "remoteType: $($property.linkEntityName)"
        }
    }
    [void]$sb.AppendFormat("Entity-Type {0}", $EntityName).AppendLine()
    [void]$sb.AppendLine("Properties:")
    [void]$sb.Append(($definitions.$EntityName.properties |Select-Object name, locname, logical_type, @{name = 'details'; expression = $detailsScript } | Format-Table | Out-String))
    [void]$sb.AppendLine("Associations:")
    [void]$sb.Append(($definitions.$EntityName.associations | Select-Object name, locname, cardinality, @{name = 'details'; expression = $detailsScript } | Format-Table | Out-String))

    return $sb.ToString()

    # return $result.properties
}