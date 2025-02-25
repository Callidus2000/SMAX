function Add-SMAXAttachement {
    <#
    .SYNOPSIS
    Uploads an Attachement

    .DESCRIPTION
    Uploads an Attachement

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .PARAMETER Path
    The Path to the File to Upload


    .EXAMPLE

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$Path
    )
    $file = get-item -path $Path
    $FormTemplate = @'
--{0}
Content-Disposition: form-data; name="files[]"; filename="{1}"
Content-Type: {2}

{3}
--{0}--

'@
    $enc = [System.Text.Encoding]::GetEncoding("iso-8859-1")
    $bytes = [System.IO.File]::ReadAllBytes($File.FullName)
    $data = $enc.GetString($bytes)
    $ContentType = "application/octet-stream"
    $fileName = $file.name
    $body = $FormTemplate -f $boundary, $fileName, $ContentType, $data
    $FormContentType = "multipart/form-data; boundary=$boundary"

    $apiCallParameter = @{
        EnableException     = $EnableException
        ContentType         = $FormContentType
        Connection          = $Connection
        LoggingAction       = "Add-SMAXAttachement"
        LoggingActionValues = @($Path)
        method              = "POST"
        Path                = "/frs/file-list"
        Body                = $body
        Headers             = @{
            "content-disposition" = "attachment; filename=`"$fileName`""
        }
    }
    Invoke-SMAXAPI @apiCallParameter
}