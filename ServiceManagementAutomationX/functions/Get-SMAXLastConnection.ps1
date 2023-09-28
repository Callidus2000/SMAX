function Get-SMAXLastConnection {
  <#
  .SYNOPSIS
      Retrieves the last saved connection to the Micro Focus SMAX server.

  .DESCRIPTION
      The Get-SMAXLastConnection function retrieves the last saved connection to
      the Micro Focus SMAX server from the configuration. It is used to reuse
      previously configured connections when interacting with the SMAX API.

  .PARAMETER EnableException
      Indicates whether to enable exception handling. If set to $true (default),
      the function will throw an exception when there is no last saved connection.
      If set to $false, it will return $null when no last connection is available.

  .EXAMPLE
      Get-SMAXLastConnection

      Description:
      Retrieves the last saved connection to the Micro Focus SMAX server.

  .NOTES
      Date:   September 28, 2023
  #>
    [CmdletBinding()]
    param (
		[bool]$EnableException = $true
    )
    $connection = Get-PSFConfigValue -FullName 'ServiceManagementAutomationX.LastConnection'
    if ($null -eq $connection -and $EnableException){
        throw "No last connection available"
    }
    return $connection
}