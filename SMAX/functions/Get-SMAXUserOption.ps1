function Get-SMAXUserOption {
    <#
.SYNOPSIS
    Retrieves user options of an entity from the Micro Focus SMAX API.

.DESCRIPTION
    The Get-SMAXUserOption function retrieves user options for a specified user
    ID from the Micro Focus SMAX API. User options are used to store user-specific
    settings and preferences.

.PARAMETER Connection
    Specifies the connection to the Micro Focus SMAX server. If not provided, it
    will use the last saved connection obtained using the Get-SMAXLastConnection
    function.

.PARAMETER EnableException
    Indicates whether to enable exception handling. If set to $true (default),
    the function will throw exceptions on API errors. If set to $false, it will
    return error information as part of the result.

.PARAMETER Id
    Specifies the ID of the user options for whom further information is retrieved.

.EXAMPLE
    $request=Get-SMAXEntity -EntityType Request -Properties UserOptionsName -Id 123
    Get-SMAXUserOption -Id $request.UserOptionsName

    Description:
    Retrieves user options for the Request with ID "12345" from the SMAX server.

.NOTES
    Date:   September 28, 2023
#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byId")]
        [string]$Id
    )
    $apiCallParameter = @{
        EnableException        = $EnableException
        Connection             = $Connection
        ConvertJsonAsHashtable = $false
        LoggingAction          = "Get-SMAXUserOption"
        LoggingActionValues    = @($Id)
        method                 = "GET"
        Path                   = "/user-options/full/$Id"
    }

    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json)"
    $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
    return $result
}