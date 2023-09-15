function Get-SMAXMetaEntityDescription {
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
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [switch]$RawDescription,
        [bool]$EnableException = $true
    )
    if (-not $Global:ENTITYDESCRIPTION) {

        $apiCallParameter = @{
            EnableException = $EnableException
            Connection      = $Connection
            LoggingAction   = "Get-SMAXMetaEntityDescription"
            # LoggingActionValues = @($addressList.count, $explicitADOM)
            method          = "GET"
            Path            = "/metadata/ui/entity-descriptors"
        }
        $result = Invoke-SMAXAPI @apiCallParameter
        $Global:ENTITYDESCRIPTION = $result.entity_descriptors | Where-Object domain -NotMatch 'sample'
    }
    if ($RawDescription){
        return $Global:ENTITYDESCRIPTION
    }
}