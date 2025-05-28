function Remove-SMAXEntity {
    <#
    .SYNOPSIS
    Removes Entities in Micro Focus SMAX.

    .DESCRIPTION
    The Remove-SMAXEntity function allows you to remove Entities based on their ID.

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
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        [parameter(mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "byEntityId")]
        [string[]]$Id
    )

    begin {
        $entityList = New-Object System.Collections.ArrayList
    }
    process {
        Write-PSFMessage "processing `$Id: $($Id -join ',')"
        foreach ($entityID in $Id) {
            $entity = [PSCustomObject]@{
                "entity_type" = $EntityType
                "properties"  = @{
                    Id=$entityID
                }
            }
            Write-PSFMessage "adding `$entity: $($entity|ConvertTo-Json -WarningAction SilentlyContinue -Compress -Depth 4)"
            [void]$entityList.Add($entity)
        }
    }
    end {
        $apiCallParameter = @{
            EnableException        = $EnableException
            Connection             = $Connection
            ConvertJsonAsHashtable = $false
            LoggingAction          = "Remove-SMAXEntity"
            LoggingActionValues    = @(  ($Id -join ','), $EntityType)
            method                 = "POST"
            Path                   = "/ems/bulk"
            body                   = @{
                entities  = $entityList.ToArray()
                operation = "DELETE"
            }
        }
        Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5)"
        $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
        Write-PSFMessage "`$result=$($result|ConvertTo-Json -WarningAction SilentlyContinue -Depth 5)"

        return $result
    }
}