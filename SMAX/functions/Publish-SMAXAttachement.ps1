function Publish-SMAXAttachement {
    #angelehnt an https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.4#example-6-simplified-multipart-form-data-submission
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$Path
    )

    $apiCallParameter = @{
        EnableException     = $false
        Connection          = $Connection
        LoggingAction       = "Publish-SMAXAttachement"
        LoggingActionValues = @($Path)
        method              = "POST"
        Path                = "/frs/file-list"
        InFile              = $Path
    }
    $Response = Invoke-SMAXAPI @apiCallParameter #| ConvertFrom-Json
    $Response
}