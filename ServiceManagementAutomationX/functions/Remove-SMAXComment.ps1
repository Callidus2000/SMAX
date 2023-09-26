function Remove-SMAXComment {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntity")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntity")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$Id,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntity")]
        $Comment,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        $CommentId
    )
    if ($Comment){
        $CommentId=$Comment.id
    }
    if ([string]::IsNullOrEmpty($CommentId)) {
        Stop-PSFFunction -EnableException $EnableException -Message "CommentId empty or missing"
        return
    }
    $apiCallParameter = @{
        EnableException        = $EnableException
        Connection             = $Connection
        ConvertJsonAsHashtable = $false
        LoggingAction          = "Remove-SMAXComment"
        LoggingActionValues    = @( $CommentId, $Id, $EntityName)
        method                 = "DELETE"
        Path                   = "/collaboration/comments/$EntityName/$Id/$CommentId"
        # body                   = $Comment|ConvertTo-PSFHashtable
    }
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -Depth 5)"
    $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
    Write-PSFMessage "`$result=$($result|ConvertTo-Json -Depth 5)"

    return $result
}