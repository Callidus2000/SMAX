function Get-SMAXConfPrefix {
    <#
    .SYNOPSIS
    Returns the PSF Config Prefix of either the already existing connection or from the last opened one.

    .DESCRIPTION
    Returns the PSF Config Prefix of either the already existing connection or from the last opened one.

    .PARAMETER Connection
    The existing connection to SMAX

    .EXAMPLE
    Get-SMAXConfPrefix

    Returns the internal prefix string

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        $Connection = (Get-SMAXLastConnection -EnableException $false)
    )
    if (-not [string]::IsNullOrEmpty($Connection)){
        Write-PSFMessage "Returning Prefix from Connection"
        return $Connection.psfConfPrefix
    }
    Write-PSFMessage "Returning Prefix from SMAX.lastConfPrefix"
    Get-PSFConfigValue -FullName 'SMAX.lastConfPrefix'
}