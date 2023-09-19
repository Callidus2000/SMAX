function Remove-SMAXComment {
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
        LoggingAction          = "Remove-SMAXComment"
        LoggingActionValues    = @( $comment.ID, $Id, $EntityName)
        method                 = "DELETE"
        Path                   = "/collaboration/comments/$EntityName/$Id/$($Comment.Id)"
        # body                   = $Comment|ConvertTo-PSFHashtable
    }
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -Depth 5)"
    $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
    Write-PSFMessage "`$result=$($result|ConvertTo-Json -Depth 5)"

    return $result
}