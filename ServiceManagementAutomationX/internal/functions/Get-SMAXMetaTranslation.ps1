function Get-SMAXMetaTranslation {
    <#
    .SYNOPSIS
    Adds new addresses to the given ADOM.

    .DESCRIPTION
    Adds new addresses to the given ADOM.

    .PARAMETER Connection
    The API connection object.

    .PARAMETER EnableException
	Should Exceptions been thrown?

    .EXAMPLE

    .NOTES
    General notes
    #>
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        $Locale,
        [bool]$EnableException = $true
    )
    if ([string]::IsNullOrEmpty($Locale)) {
        $currentUser = Get-SMAXCurrentUser -Connection $Connection
        $Locale = $currentUser.Locale
    }
    $apiCallParameter = @{
        EnableException        = $EnableException
        Connection             = $Connection
        LoggingAction          = "Get-SMAXMetaEntityDescription"
        # LoggingActionValues = @($addressList.count, $explicitADOM)
        method                 = "GET"
        Path                   = "/l10n/bundles/saw/$Locale"
        ConvertJsonAsHashtable = $true
    }
    $result = Invoke-SMAXAPI @apiCallParameter
    # write-host "`$result=$result"
    $dictionary=@{}
    foreach ($resourceTable in $result.Bundles.Resources) {
        $resourceTable.GetEnumerator() | Where-Object { $_.value } | ForEach-Object {
            $key = $_.name
            $dictionary.$key=$_.value
        }
    }
    Write-PSFMessage "Gathered $($dictionary.Keys.Count) translations"
    return $dictionary
}