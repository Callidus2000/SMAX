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

    .EXAMPLE
    $request=Get-SMAXEntity -EntityName Request -Properties RequestAttachments -Id 483963
    $attachementData=($request.RequestAttachments|ConvertFrom-Json).complexTypeProperties.properties
    Get-SMAXAttachement -Connection $connection -Id $attachementData.id[0] -OutFile $attachementData.file_name[0]

    Downloads the first attachement of the given Request

    .NOTES
    General notes
    #>
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