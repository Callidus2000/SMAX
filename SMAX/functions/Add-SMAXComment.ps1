function Add-SMAXComment {
    <#
    .SYNOPSIS
    Adds comments to entities in the Service Management Automation X (SMAX) platform.

    .DESCRIPTION
    The Add-SMAXComment function allows you to add comments to SMAX entities, such as incidents.
    You can specify the entity name, ID, and an array of comments to add.

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .PARAMETER EntityType
    Specifies the name of the entity to which comments will be added.

    .PARAMETER Id
    Specifies the ID of the entity to which comments will be added.

    .PARAMETER Comment
    Specifies the comments to add to the entity. You can provide an array of comment objects.

    .EXAMPLE
    $comment=New-SMAXComment -ActualInterface API -Body "This is my comment" -CommentFrom Agent -CommentTo User -FunctionalPurpose Diagnosis -Media UI
    Add-SMAXComment -Connection $connection -Comment $comment -EntityType Request -Id 4711

    Creates a comment and adds it to the Request 4711

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$Id,
        [parameter(mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "byEntityId")]
        [object[]]$Comment
    )
    begin {
        $commentList = @()
    }
    process {
        $commentList += $Comment
    }
    end {
        $apiCallParameter = @{
            EnableException        = $EnableException
            Connection             = $Connection
            ConvertJsonAsHashtable = $false
            LoggingAction          = "Add-SMAXComment"
            LoggingActionValues    = @( $commentList.Count, $Id, $EntityType)
            method                 = "POST"
            Path                   = "/collaboration/comments/bulk/$EntityType/$Id"
            body                   = ,$commentList|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5
        }
        Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5)"
        $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
        Write-PSFMessage "`$result=$($result|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5)"

        # return $result
       # Invoke-SMAXBulk @bulkParameter
    }
}