function Get-SMAXCurrentUser{
    <#
    .SYNOPSIS
    Adds new addresses to the given ADOM.

    .DESCRIPTION
    Adds new addresses to the given ADOM.

    .PARAMETER Connection
    The API connection object.


    .PARAMETER EnableException
	Should Exceptions been thrown?

    .EXAMPLE

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
            LoggingAction       = "Get-SMAXEntityDescription"
            # LoggingActionValues = @($addressList.count, $explicitADOM)
            method              = "GET"
            Path            = "/personalization/person/me"
        }
        $result = Invoke-SMAXAPI @apiCallParameter
        return $result.entities.properties
}