function Get-SMAXMetaTranslation {
    <#
.SYNOPSIS
Retrieves translations for a specific locale in the Service Management Automation X (SMAX) platform.

.DESCRIPTION
The Get-SMAXMetaTranslation function allows you to retrieve translations for a specified locale
in the SMAX platform. You can provide a connection and specify the desired locale.

.PARAMETER Connection
Specifies the SMAX connection to use. If not provided, it uses the last established connection.

.PARAMETER Locale
Specifies the locale for which translations are retrieved. If not provided, it uses the locale
associated with the current user obtained from the connection.

.PARAMETER EnableException
Indicates whether exceptions should be enabled. By default, exceptions are enabled.

.EXAMPLE
PS C:\> Get-SMAXMetaTranslation -Connection $conn -Locale "fr-FR"

This example retrieves translations for the French (France) locale in the SMAX platform.

.EXAMPLE
PS C:\> Get-SMAXMetaTranslation -Connection $conn

This example retrieves translations for the locale associated with the current user in the SMAX platform.

.NOTES
File Name      : Get-SMAXMetaTranslation.ps1

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
        method                 = "GET"
        Path                   = "/l10n/bundles/saw/$Locale"
        ConvertJsonAsHashtable = $true
    }
    $result = Invoke-SMAXAPI @apiCallParameter
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