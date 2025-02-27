function Publish-SMAXAttachement {
    <#
    .SYNOPSIS
    Publishes an attachment to the Micro Focus SMAX server.

    .DESCRIPTION
    The Publish-SMAXAttachement function uploads a file to the Micro Focus
    SMAX server as an attachment. It uses the Invoke-SMAXAPI function to
    perform the API call and handles the necessary parameters for the
    attachment upload.

    .PARAMETER Connection
    Specifies the connection object to the SMAX server. If not provided, the
    last connection is used.

    .PARAMETER EnableException
    Indicates whether to enable exceptions. Default is $true.

    .PARAMETER Path
    Specifies the path to the file to be uploaded as an attachment.

    .EXAMPLE
    PS C:\> Publish-SMAXAttachement -Path "C:\file.txt"

    Uploads the file "file.txt" to the SMAX server as an attachment.

    #>
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