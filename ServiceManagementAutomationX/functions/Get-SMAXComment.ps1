function Get-SMAXComment {
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
    $result = Invoke-SMAXAPI @apiCallParameter #| Where-Object { $_.properties}
    # foreach ($item in $result) {
    #     Add-Member -InputObject $item.properties -MemberType NoteProperty -Name related -Value $item.related_properties
    #     $item.properties.PSObject.TypeNames.Insert(0, "SMAX.$($item.entity_type)")
    # }
    # if($FlattenResult){
    #     return $result.properties|ConvertTo-SMAXFlatObject
    # }

    return $result #.properties

}