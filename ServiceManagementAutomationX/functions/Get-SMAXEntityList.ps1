function Get-SMAXEntityList {
    <#
    .SYNOPSIS
        Retrieves a list of entity names from the Micro Focus SMAX API configuration.

    .DESCRIPTION
        The Get-SMAXEntityList function retrieves a list of entity names and their
        localized names from the Micro Focus SMAX API configuration. This can be
        useful for querying available entities in the SMAX system.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it
        will use the last saved connection obtained using the Get-SMAXLastConnection
        function.

    .EXAMPLE
        Get-SMAXEntityList

        Description:
        Retrieves a list of entity names and their localized names from the SMAX
        configuration.

    .NOTES
        Date:   September 28, 2023
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection -EnableException $false)
    )
    return Get-PSFConfigValue -FullName "$(Get-SMAXConfPrefix -Connection $Connection).tepp.EntryNames" | Select-Object @{name = "name"; expression = { $_.Text } }, @{name = "locName"; expression = { $_.ToolTip } } | Sort-Object -Property locName
    $fullDescription = Get-SMAXMetaEntityDescription -Connection $Connection
    return $fullDescription | Select-Object -Property locName, name | Sort-Object -Property locName
}