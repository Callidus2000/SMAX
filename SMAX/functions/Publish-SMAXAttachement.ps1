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

    try {
        $apiCallParameter = @{
            # EnableException     = $EnableException
            EnableException     = $false
            # ContentType         = $FormContentType
            Connection          = $Connection
            LoggingAction       = "Publish-SMAXAttachement"
            LoggingActionValues = @($Path)
            method              = "POST"
            Path                = "/frs/file-list"
            # Body                = $body
            # Body                = $MultipartContent
            InFile=$Path
            # Headers             = @{
            #     # "content-disposition" = "attachment; filename=`"$fileName`""
            #     "fs_filename"         = "$fileName"
            # }
        }
        $Response = Invoke-SMAXAPI @apiCallParameter #| ConvertFrom-Json
        $Response

        # Invoke-PSFProtectedCommand -Action "Uploading, if required multiple times" -ScriptBlock {
        #     $ContentType = 'application/octet-stream'
        #     $uri = $Connection.WebServiceRoot + "/frs/file-list"

        #     $FileStream = [System.IO.FileStream]::new($Path, [System.IO.FileMode]::Open)
        #     $FileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
        #     $FileHeader.Name = 'files[]'
        #     $FileHeader.FileName = Split-Path -leaf $Path
        #     $FileContent = [System.Net.Http.StreamContent]::new($FileStream)
        #     $FileContent.Headers.ContentDisposition = $FileHeader
        #     $FileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($ContentType)

        #     $MultipartContent = [System.Net.Http.MultipartFormDataContent]::new()
        #     $MultipartContent.Add($FileContent)

        #     Write-PSFMessage -Message "Path=$Path" -Level host
        #     try {
        #         # $Response = Invoke-WebRequest -Body $MultipartContent -Method 'POST' -Uri $Uri -WebSession $connection.WebSession  -verbose
        #     }
        #     catch {
        #         write-host $_
        #         throw $_
        #     }

        #     $result = $Response.Content | ConvertFrom-Json
        #     if ($null -ne $FileStream) {
        #         $FileStream.Close()
        #         $FileStream.Dispose()
        #     }
        #     if ($null -ne $MultipartContent) {
        #         $MultipartContent.Dispose()
        #     }

        #     $global:hubba = $result
        #     # Write-PSFMessage -Message "Upload response: $($result|ConvertTo-Json -Compress)" -Level host
        #     # if ($null -eq $result.guid){
        #     if ($false -eq $result.success) {
        #         Stop-PSFFunction -Message "Upload failed, response: $($result|ConvertTo-Json -Compress)" #-Level Critical
        #         throw "Murks"
        #     }
        #     else {
        #         $result
        #     }
        # } -RetryCount 4 -RetryWait ([timespan]::FromSeconds(1)) #-Level Host
    }
    finally {
        # write-host "Schließen des Dateistreams"
        # Schließen des Dateistreams und Entsorgen des MultipartContent
        if ($null -ne $FileStream) {
            $FileStream.Close()
            $FileStream.Dispose()
        }
        if ($null -ne $MultipartContent) {
            $MultipartContent.Dispose()
        }
    }
}