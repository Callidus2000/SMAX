function Get-SMAXComment {
    <#
    .SYNOPSIS
    Retrieves all comments of a given entity

    .DESCRIPTION
    Retrieves all comments of a given entity

    .PARAMETER Connection
    The connection to SMAX

    .PARAMETER EnableException
    If set to $true, an exception will be thrown in case of an error

    .PARAMETER EntityName
    The name of the entity

    .PARAMETER Id
    The Id of the entity

    .PARAMETER PrivacyType
    Filter the comments based on the privavy types 'Public', 'Internal'

    .EXAMPLE
    Get-SMAXComment -Connection $connection -EntityName Request -Id 374344

    Retrieves all comments of Request 374344

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [int]$Id,
        [ValidateSet('Public', 'Internal')]
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$PrivacyType
    )
    $apiCallParameter = @{
        EnableException        = $EnableException
        EnablePaging           = $false
        Connection             = $Connection
        ConvertJsonAsHashtable = $false
        LoggingAction          = "Get-SMAXComment"
        LoggingActionValues    = @($EntityName, $Id)
        method                 = "GET"
        Path                   = "/collaboration/comments/$EntityName/$Id"
        URLParameter           = @{}
    }
    if($PrivacyType){
        $apiCallParameter.URLParameter.PrivacyType=$PrivacyType.ToUpper()
    }
    Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json)"
    $result = Invoke-SMAXAPI @apiCallParameter

    return $result

}