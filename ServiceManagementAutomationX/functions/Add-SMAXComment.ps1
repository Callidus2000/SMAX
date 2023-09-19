function Add-SMAXComment {
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
            LoggingActionValues    = @( $commentList.Count, $Id, $EntityName)
            method                 = "POST"
            Path                   = "/collaboration/comments/bulk/$EntityName/$Id"
            body                   = ,$commentList|ConvertTo-Json -Depth 5
        }
        Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json -Depth 5)"
        $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
        Write-PSFMessage "`$result=$($result|ConvertTo-Json -Depth 5)"

        # return $result
       # Invoke-SMAXBulk @bulkParameter
    }
}