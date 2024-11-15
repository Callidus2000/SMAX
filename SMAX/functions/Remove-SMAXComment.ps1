function Remove-SMAXComment {
    <#
    .SYNOPSIS
    Removes a comment associated with an entity in Micro Focus SMAX.

    .DESCRIPTION
    The Remove-SMAXComment function allows you to remove a comment associated with an entity in Micro Focus SMAX.
    You can remove a comment either by specifying the entity and comment details or by providing the entity's ID
    and the comment's ID.

    .PARAMETER Connection
    Specifies the connection to the Micro Focus SMAX server. If not provided, it will use the last saved
    connection obtained using the Get-SMAXLastConnection function.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. Default is $true.

    .PARAMETER EntityType
    Specifies the name of the entity for which the comment needs to be removed. Use this parameter in the
    "byEntity" parameter set.

    .PARAMETER Id
    Specifies the ID of the entity for which the comment needs to be removed. Use this parameter in the
    "byEntity" parameter set.

    .PARAMETER Comment
    Specifies the comment object to be removed. Use this parameter in the "byEntity" parameter set. The
    object must include the .Id property

    .PARAMETER CommentId
    Specifies the ID of the comment to be removed. Use this parameter in the "byEntityId" parameter set.

    .EXAMPLE
    # Remove a comment associated with an entity using the entity's details.
    $commentObject = @{
        id = "123456"
        body = "This is a test comment."
    }
    Remove-SMAXComment -EntityType "Incident" -Id "789" -Comment $commentObject

    Description:
    Removes the comment specified by the comment object associated with the Incident with ID 789.

    .EXAMPLE
    # Remove a comment associated with an entity using the entity's ID and comment's ID.
    Remove-SMAXComment -EntityType "Change" -CommentId "987654" -Id "456"

    Description:
    Removes the comment with ID 987654 associated with the Change with ID 456.

    .NOTES
    Date: September 28, 2023
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntity")]
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
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
        LoggingActionValues    = @( $CommentId, $Id, $EntityType)
        method                 = "DELETE"
        Path                   = "/collaboration/comments/$EntityType/$Id/$CommentId"
        # body                   = $Comment|ConvertTo-PSFHashtable
    }
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5)"
    $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
    Write-PSFMessage "`$result=$($result|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5)"

    return $result
}