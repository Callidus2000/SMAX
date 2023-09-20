function Get-SMAXUserOption {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byId")]
        [string]$Id
    )
    $apiCallParameter = @{
        EnableException        = $EnableException
        Connection             = $Connection
        ConvertJsonAsHashtable = $false
        LoggingAction          = "Get-SMAXUserOption"
        LoggingActionValues    = @($Id)
        method                 = "GET"
        Path                   = "/user-options/full/$Id"
    }

    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json)"
    $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
    return $result
}