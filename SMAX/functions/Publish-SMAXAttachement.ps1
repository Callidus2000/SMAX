function Publish-SMAXAttachement {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$Path
    )
    $boundary=(New-Guid).guid
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
        # EnableException     = $EnableException
        EnableException     = $false
        ContentType         = $FormContentType
        Connection          = $Connection
        LoggingAction       = "Publish-SMAXAttachement"
        LoggingActionValues = @($Path)
        method              = "POST"
        Path                = "/frs/file-list"
        Body                = $body
        Headers             = @{
            "content-disposition" = "attachment; filename=`"$fileName`""
        }
    }
    Invoke-PSFProtectedCommand -Action "Uploading, if required multiple times" -ScriptBlock {
        # Write-PSFMessage -Message "Path=$Path" -Level host
        $result=Invoke-SMAXAPI @apiCallParameter|ConvertFrom-Json
        $global:hubba=$result
        # Write-PSFMessage -Message "Upload response: $($result|ConvertTo-Json -Compress)" -Level host
        # if ($null -eq $result.guid){
        if ($false -eq $result.success){
            Stop-PSFFunction -Message "Upload failed, response: $($result|ConvertTo-Json -Compress)" #-Level Critical
            throw "Murks"
        }else{
            $result
        }
    } -RetryCount 4 -RetryWait ([timespan]::FromSeconds(2)) #-Level Host
}