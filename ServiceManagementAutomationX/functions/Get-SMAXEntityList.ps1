function Get-SMAXEntityList {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
    $Connection = (Get-SMAXLastConnection)
    )
    $fullDescription = Get-SMAXMetaEntityDescription -Connection $Connection -RawDescription
    return $fullDescription.name
}