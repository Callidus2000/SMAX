function Get-SMAXAttachement {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$Id,
        $OutFile
    )

    $apiCallParameter = @{
        EnableException        = $EnableException
        Connection             = $Connection
        LoggingAction          = "Get-SMAXAttachement"
        LoggingActionValues    = @($Id)
        method                 = "GET"
        Path                   = "/frs/file-list/$Id"
        OutFile            = $OutFile
    }

    Invoke-SMAXAPI @apiCallParameter
}