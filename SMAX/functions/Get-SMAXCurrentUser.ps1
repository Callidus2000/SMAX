function Get-SMAXCurrentUser{
    <#
    .SYNOPSIS
        Retrieves the current user's properties from the Micro Focus SMAX API.

    .DESCRIPTION
        The Get-SMAXCurrentUser function is used to retrieve the properties of the currently logged-in
        user from the Micro Focus SMAX API. It sends a GET request to the "/personalization/person/me"
        endpoint of the SMAX API and returns the user's properties.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it will use the last
        saved connection obtained using the Get-SMAXLastConnection function.

    .PARAMETER EnableException
        Indicates whether to enable exception handling. If set to $true (default), the function will
        throw exceptions on API errors. If set to $false, it will return error information as part of the result.

    .EXAMPLE
        Get-SMAXCurrentUser

        Description:
        Retrieves the current user's properties using the last saved SMAX connection and enables exception handling.

    .EXAMPLE
        Get-SMAXCurrentUser -Connection $MyConnection -EnableException $false

        Description:
        Retrieves the current user's properties using a specified SMAX connection and disables exception handling.

    .NOTES
    General notes
    #>
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true
    )

        $apiCallParameter = @{
            EnableException     = $EnableException
            Connection          = $Connection
            LoggingAction       = "Get-SMAXMetaEntityDescription"
            # LoggingActionValues = @($addressList.count, $explicitADOM)
            method              = "GET"
            Path            = "/personalization/person/me"
        }
        $result = Invoke-SMAXAPI @apiCallParameter
        return $result.entities.properties
}