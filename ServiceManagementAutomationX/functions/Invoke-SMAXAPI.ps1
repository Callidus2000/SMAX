function Invoke-SMAXAPI {
    <#
    .SYNOPSIS
    Generic API Call to the SMAX API.

    .DESCRIPTION
    Generic API Call to the SMAX API. This function is a wrapper for the usage of Invoke-WebRequest. It handles some annoying repetitive tasks which occur in most use cases. This includes (list may be uncompleted)
    - Connecting to a server with authentication
    - Parsing API parameter
    - Handling $null parameter
    - Paging for API endpoints which do only provide limited amounts of datasets

    .PARAMETER Connection
    Object of Class , stores the authentication Token and the API Base-URL. Can be obtained with Connect-SMAX.

    .PARAMETER Path
    API Path to the REST function

    .PARAMETER Body
    Parameter for the API call; The hashtable is Converted to the POST body by using ConvertTo-Json

    .PARAMETER Header
    Additional Header Parameter for the API call; currently dropped but needed as a parameter for the *-SMAXAR* functions

    .PARAMETER URLParameter
    Parameter for the API call; Converted to the GET URL parameter set.
    Example:
    {
        id=4
        name=Jon Doe
    }
    will result in "?id=4&name=Jon%20Doe" being added to the URL Path

    .PARAMETER Method
    HTTP Method, Get/Post/Delete/Put/...

    .PARAMETER ContentType
    HTTP-ContentType, defaults to "application/json;charset=UTF-8"

    .PARAMETER Parameter
    The values for the parameter body part of the API request.

    .PARAMETER LoggingAction
    compare ~\ServiceManagementAutomationX\en-us\strings.psd1
    The given string with the prefix "APICall." will be used for logging purposes.

    .PARAMETER LoggingActionValues
    compare ~\ServiceManagementAutomationX\en-us\strings.psd1
    Array of placeholder values.

    .PARAMETER LoggingLevel
    On which level should die diagnostic Messages be logged?
    Defaults to PSFConfig "ServiceManagementAutomationX.Logging.Api"

    .PARAMETER RevisionNote
    The change note which should be saved for this revision, see about_RevisionNote

    .PARAMETER ConvertJsonAsHashtable
    If set the json result will be converted as a HashTable
    .PARAMETER EnablePaging
    Wenn die API mit Paging arbeitet, kann über diesn Parameter ein automatisches Handling aktivieren.
    Dann werden alle Pages abgehandelt und nur die items zurückgeliefert.

    .PARAMETER EnableException
    If set to true, inner exceptions will be rethrown. Otherwise the an empty result will be returned.

    .EXAMPLE
    $result = Invoke-SMAXAPI -connection $this -path "" -method POST -body @{login = $credentials.UserName; password = $credentials.GetNetworkCredential().Password; language = "1"; authType = "sql" } -hideparameters $true

    Login to the service

    .NOTES
    General notes
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]

    param (
        $Connection = (Get-SMAXLastConnection),
        [string]$Path,
        $Body,
        [Hashtable] $Header,
        [Alias("Query")]
        [Hashtable] $URLParameter,
        [parameter(mandatory = $true)]
        [Microsoft.Powershell.Commands.WebRequestMethod]$Method,
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $false,
        [string]$LoggingAction = "Invoke-SMAXAPI",
        [ValidateSet("Critical", "Important", "Output", "Host", "Significant", "VeryVerbose", "Verbose", "SomewhatVerbose", "System", "Debug", "InternalComment", "Warning")]
        [string]$LoggingLevel = (Get-PSFConfigValue -FullName "ServiceManagementAutomationX.Logging.Api" -Fallback "Verbose"),
        [switch]$ConvertJsonAsHashtable,
        [string[]]$LoggingActionValues = ""
    )
    if (-not $Connection) {
        Write-PSFMessage "Keine Connection als Parameter erhalten, frage die letzte ab"
        $Connection = Get-SMAXLastConnection -EnableException $EnableException
        if (-not $Connection) {
            Stop-PSFFunction "No last connection available" -EnableException $EnableException -AlwaysWarning
            return
        }
    }
    $apiCallParameter = $PSBoundParameters | ConvertTo-PSFHashtable -Exclude LoggingActionValues, RevisionNote, LoggingAction
    if ($EnablePaging){
        $apiCallParameter.PagingHandler='SMAX.PagingHandler'
    }
    # return Invoke-ARAHRequest @requestParameter -PagingHandler 'Dracoon.PagingHandler'

    $connection.WebSession.Cookies = [System.Net.CookieContainer]::new()
    $connection.WebSession.Cookies.Add($Connection.authCookie)


    Invoke-PSFProtectedCommand -ActionString "APICall.$LoggingAction" -ActionStringValues (,$requestId+$LoggingActionValues) -ScriptBlock {
        $result = Invoke-ARAHRequest @apiCallParameter #-Verbose -PagingHandler 'SMAX.PagingHandler'

        # if ($null -eq $result) {
        #     Stop-PSFFunction -Message "No Result delivered" -EnableException $true
        #     return $false
        # }
        # $statusCode = $result.result.status.code
        # if ($statusCode -ne 0) {
        #     Stop-PSFFunction -Message "API-Error, statusCode: $statusCode, Message $($result.result.status.Message)" -EnableException $EnableException -StepsUpward 3 #-AlwaysWarning
        # }
        # $connection.forti.lastApiAccessDate=Get-Date
            # Write-PSFMessage "`$result=$($result|convertto-json)"
    } -PSCmdlet $PSCmdlet  -EnableException $false -Level $LoggingLevel
    if ((Test-PSFFunctionInterrupt) -and $EnableException) {
        Throw "API-Error, statusCode: $statusCode, Message $($result.result.status.Message)" #-EnableException $true -StepsUpward 3 #-AlwaysWarning
    }
    return $result
}