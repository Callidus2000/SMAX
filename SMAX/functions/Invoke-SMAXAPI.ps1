function Invoke-SMAXAPI {
    <#
    .SYNOPSIS
        Invokes the Micro Focus SMAX API to perform various operations.

    .DESCRIPTION
        The Invoke-SMAXAPI function is used to interact with the Micro Focus SMAX
        API to perform operations such as retrieving data, creating entities, updating
        entities, and more. It supports various HTTP methods and provides options for
        handling API responses.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it
        will use the last saved connection obtained using the Get-SMAXLastConnection
        function.

    .PARAMETER Path
        Specifies the API endpoint path for the operation.

    .PARAMETER Body
        Specifies the request body for the API operation.
        Hashtables are Converted to the POST body by using ConvertTo-Json

    .PARAMETER Header
        Specifies custom HTTP headers for the API request.

    .PARAMETER URLParameter
        Specifies URL parameters for the API request; Converted to the GET URL parameter set.
        Example:
        {
            id=4
            name=Jon Doe
        }
        will result in "?id=4&name=Jon%20Doe" being added to the URL Path

    .PARAMETER Method
        Specifies the HTTP request method (e.g., GET, POST, PUT, DELETE).

    .PARAMETER EnableException
        Indicates whether to enable exception handling. If set to $true (default),
        the function will throw exceptions on API errors. If set to $false, it will
        return error information as part of the result.

    .PARAMETER EnablePaging
        Enables paging for large result sets. By default, paging is disabled.

    .PARAMETER LoggingAction
        Specifies the name of the logging action for tracking purposes.

    .PARAMETER LoggingLevel
        Specifies the logging level for the API operation. Valid values are:
        Critical, Important, Output, Host, Significant, VeryVerbose, Verbose,
        SomewhatVerbose, System, Debug, InternalComment, and Warning.

    .PARAMETER ConvertJsonAsHashtable
        If specified, the JSON response from the API is converted into a hashtable.

    .PARAMETER OutFile
        Specifies a file path to which the API response is saved.

    .PARAMETER LoggingActionValues
        Additional values to be associated with the logging action.

    .EXAMPLE
        $response = Invoke-SMAXAPI -Connection $MyConnection -Path "/incidents/123"
        -Method Get

        Description:
        Sends a GET request to retrieve information about incident ID 123.

    .EXAMPLE
        $requestBody = @{
            "Title" = "New Incident"
            "Description" = "This is a new incident."
        }
        $response = Invoke-SMAXAPI -Connection $MyConnection -Path "/incidents" -Method Post
        -Body $requestBody

        Description:
        Sends a POST request to create a new incident with the specified request body.

    .NOTES
        Date:   September 28, 2023
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
        [string]$LoggingLevel = (Get-PSFConfigValue -FullName "SMAX.Logging.Api" -Fallback "Verbose"),
        [switch]$ConvertJsonAsHashtable,
        [string]$OutFile,
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
    if ($connection.GetType().Name -ne 'ARAHConnection') {
        Write-PSFMessage -Level Host "Wandle Connection aus OldConnection um"
        $Connection = Connect-SMAX -OldConnection $Connection
    }
    else {
        Write-PSFMessage -Level Host "Wandle Connection aus OldConnection NICHT um"
    }
    $apiCallParameter = $PSBoundParameters | ConvertTo-PSFHashtable -Exclude LoggingActionValues, RevisionNote, LoggingAction
    if ($EnablePaging) {
        $apiCallParameter.PagingHandler = 'SMAX.PagingHandler'
    }

    $connection.WebSession.Cookies = [System.Net.CookieContainer]::new()
    $connection.WebSession.Cookies.Add($Connection.authCookie)


    Invoke-PSFProtectedCommand -ActionString "APICall.$LoggingAction" -ActionStringValues (, $requestId + $LoggingActionValues) -ScriptBlock {
        $result = Invoke-ARAHRequest @apiCallParameter #-Verbose -PagingHandler 'SMAX.PagingHandler'

    } -PSCmdlet $PSCmdlet  -EnableException $false -Level $LoggingLevel
    if ((Test-PSFFunctionInterrupt) -and $EnableException) {
        Throw "API-Error, statusCode: $statusCode, Message $($result.result.status.Message)" #-EnableException $true -StepsUpward 3 #-AlwaysWarning
    }
    return $result
}