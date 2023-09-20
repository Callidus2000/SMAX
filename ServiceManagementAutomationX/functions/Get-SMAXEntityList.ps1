function Get-SMAXEntityList {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
    $Connection = (Get-SMAXLastConnection -EnableException $false)
    )
    return Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).tepp.EntryNames" | Select-Object @{name = "name"; expression = { $_.Text } }, @{name = "locName"; expression = { $_.ToolTip } } | Sort-Object -Property locName
    $fullDescription = Get-SMAXMetaEntityDescription -Connection $Connection -RawDescription
    return $fullDescription|Select-Object -Property locName,name|Sort-Object -Property locName
}