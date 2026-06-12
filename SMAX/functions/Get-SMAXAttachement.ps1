function Get-SMAXAttachement {
    <#
    .SYNOPSIS
    Downloads an Attachement

    .DESCRIPTION
    Downloads an Attachement

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .PARAMETER Id
    The ID of the attachement

    .PARAMETER OutFile
    The destination path to the file

    .PARAMETER Path
    Target directory. When used, the download is saved to a temp file first and
    then moved to this directory using the file name from the response headers.
    If the directory does not exist, it will be created. This parameter is mutually exclusive with OutFile.
    When using ByPath, the resolved target file path is returned.

    .PARAMETER CollisionResolution
    Determines what happens when the target file already exists. Valid values:
    Skip (default), OverWrite, AutoRename. With AutoRename the ID is appended
    to the file base name using an underscore.

    .EXAMPLE
    $request=Get-SMAXEntity -EntityType Request -Properties RequestAttachments -Id 483963
    $attachementData=($request.RequestAttachments|ConvertFrom-Json).complexTypeProperties.properties
    Get-SMAXAttachement -Connection $connection -Id $attachementData.id[0] -OutFile $attachementData.file_name[0]

    Downloads the first attachement of the given Request

    .NOTES
    General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByOutFile')]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        # [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "ByOutFile")]
        # [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "ByPath")]
        [string]$Id,
        [parameter(mandatory = $true, ParameterSetName = "ByOutFile")]
        [string]$OutFile,
        [parameter(mandatory = $true, ParameterSetName = "ByPath")]
        [string]$Path,
        [ValidateSet('Skip', 'OverWrite', 'AutoRename')]
        [string]$CollisionResolution = 'Skip'
    )

    $effectiveOutFile = $OutFile
    $shouldMoveToPath = $false
    if ($PSCmdlet.ParameterSetName -eq 'ByPath') {
        $effectiveOutFile = [System.IO.Path]::GetTempFileName()
        $shouldMoveToPath = $true
    }

    if ($PSCmdlet.ParameterSetName -eq 'ByOutFile') {
        if ($effectiveOutFile -and (Test-Path -LiteralPath $effectiveOutFile)) {
            switch ($CollisionResolution) {
                'Skip' { return }
                'AutoRename' {
                    $directory = Split-Path -Path $effectiveOutFile -Parent
                    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($effectiveOutFile)
                    $extension = [System.IO.Path]::GetExtension($effectiveOutFile)
                    $effectiveOutFile = Join-Path -Path $directory -ChildPath ("{0}_{1}{2}" -f $baseName, $Id, $extension)
                }
                'OverWrite' { }
            }
        }
    }

    $apiCallParameter = @{
        EnableException        = $EnableException
        Connection             = $Connection
        LoggingAction          = "Get-SMAXAttachement"
        LoggingActionValues    = @($Id,$effectiveOutFile,$Path,$CollisionResolution)
        method                 = "GET"
        Path                   = "/frs/file-list/$Id"
        OutFile                = $effectiveOutFile
        PassThru               = $true
    }

    $response=Invoke-SMAXAPI @apiCallParameter
    if ($shouldMoveToPath) {
        if (-not (Test-Path -LiteralPath $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }

        $fileName = $null
        $contentDisposition = $response.Headers['Content-Disposition']
        if ($contentDisposition) {
            try {
                $fileName = [System.Net.Mime.ContentDisposition]::new($contentDisposition).FileName
            }
            catch {
                $fileName = $null
            }
        }

        if ([string]::IsNullOrWhiteSpace($fileName)) {
            $fileName = "$Id"
        }

        $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
        foreach ($ch in $invalidChars) {
            $fileName = $fileName.Replace($ch, '_')
        }

        $targetFile = Join-Path -Path $Path -ChildPath $fileName
        if (Test-Path -LiteralPath $targetFile) {
            $existingTargetFile=$targetFile
            switch ($CollisionResolution) {
                'Skip' {
                    Remove-Item -LiteralPath $effectiveOutFile -Force -ErrorAction SilentlyContinue
                    write-PSFMessage "File $targetFile already exists, skipping move of downloaded file as CollisionResolution is set to Skip"
                    return $targetFile
                }
                'AutoRename' {
                    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($targetFile)
                    $extension = [System.IO.Path]::GetExtension($targetFile)
                    $targetFile = Join-Path -Path $Path -ChildPath ("{0}_{1}{2}" -f $baseName, $Id, $extension)
                    write-PSFMessage "File $existingTargetFile already exists, renaming target file to $targetFile as CollisionResolution is set to AutoRename"
                }
                'OverWrite' {
                    write-PSFMessage "File $targetFile already exists, overwriting file as CollisionResolution is set to Overwrite"
                 }
            }
        }

        Move-Item -LiteralPath $effectiveOutFile -Destination $targetFile -Force
        return $targetFile
    }
    # $response
}