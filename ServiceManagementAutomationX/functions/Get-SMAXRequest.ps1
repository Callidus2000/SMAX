function Get-SMAXRequest {
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
        # [string]$ADOM,
        # [parameter(mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "default")]
        # [object[]]$Address,
        # [switch]$Overwrite,
        # [string]$RevisionNote,
        [bool]$EnableException = $true
    )
    begin {
        # $addressList = @()
        # $explicitADOM = Resolve-SMAXAdom -Connection $Connection -Adom $ADOM
        # Write-PSFMessage "`$explicitADOM=$explicitADOM"
        # $validAttributes = Get-PSFConfigValue -FullName 'ServiceManagementAutomationX.ValidAttr.FirewallAddress'
    }
    process {
        # $Address | ForEach-Object { $addressList += $_ | ConvertTo-PSFHashtable -Include $validAttributes }
    }
    end {
        $apiCallParameter = @{
            EnableException     = $EnableException
            Connection          = $Connection
            LoggingAction       = "Add-SMAXAddress"
            # LoggingActionValues = @($addressList.count, $explicitADOM)
            method              = "GET"
            Path            = "/ems/Incident?layout=Id,Status,OwnedByPerson,OwnedByPerson.Name,OwnedByPerson.Email"
        }
        $result = Invoke-SMAXAPI @apiCallParameter
        return $result
    }
}