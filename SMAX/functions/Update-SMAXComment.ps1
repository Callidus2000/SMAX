function Update-SMAXComment {
    <#
    .SYNOPSIS
    Updates a comment in the Service Management Automation X (SMAX) platform.

    .DESCRIPTION
    The Update-SMAXComment function allows you to update an existing comment in SMAX.
    You can modify various properties of the comment using this function, such as its body
    or privacy settings.

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .PARAMETER EntityName
    Specifies the name of the entity associated with the comment.

    .PARAMETER Id
    Specifies the ID of the entity associated with the comment.

    .PARAMETER Comment
    Specifies the comment to update. This should be a comment object obtained from SMAX.

    .EXAMPLE
    PS C:\> $comment = Get-SMAXComment -Connection $conn -EntityName "Incident" -Id "123" -CommentId "456"
    PS C:\> $comment.Body = "Updated comment body"
    PS C:\> Update-SMAXComment -Connection $conn -EntityName "Incident" -Id "123" -Comment $comment

    This example retrieves a comment associated with an incident, updates its body, and then
    applies the changes to the SMAX platform.

    .NOTES
    File Name      : Update-SMAXComment.ps1

    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$Id,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        $Comment
    )
    if ([string]::IsNullOrEmpty($Comment.id)) {
        Stop-PSFFunction -EnableException $EnableException -Message "Comment.Id empty or missing"
        return
    }
    $apiCallParameter = @{
        EnableException        = $EnableException
        Connection             = $Connection
        ConvertJsonAsHashtable = $false
        LoggingAction          = "Update-SMAXComment"
        LoggingActionValues    = @( $comment.ID, $Id, $EntityName)
        method                 = "PUT"
        Path                   = "/collaboration/comments/$EntityName/$Id/$($Comment.Id)"
        body                   = $Comment|ConvertTo-PSFHashtable
    }
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -Depth 5)"
    $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
    Write-PSFMessage "`$result=$($result|ConvertTo-Json -Depth 5)"

    return $result
}