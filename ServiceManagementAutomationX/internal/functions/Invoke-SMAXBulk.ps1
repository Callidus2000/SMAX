function Invoke-SMAXBulk {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [bool]$EnablePaging = $true,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        $Data,
       	[ValidateSet('Create', 'Update')]
        [string]$Method
     )
    begin {
        $entityList = new System.Collections.ArrayList
    }
    process {
        if ([string]::IsNullOrEmpty($EntityName)) {
            Write-PSFMessage "Checking if each data object has set a PSDatatype"
            $countWithTypenames = ($Data | Where-Object { $_.psobject.TypeNames -match '^SMAX' } | Measure-Object).count
            $dataCount = ($Data | Measure-Object).count
            if ($countWithTypenames -ne $dataCount) {
                Stop-PSFFunction -EnableException $EnableException "Neither `$_.PSDataType nor -EntityName param set"
                $entityList.Clear()
                return
            }
        }
        foreach ($obj in $Data) {
            $localEntityName = $obj.psobject.TypeNames -match '^SMAX' -replace 'SMAX\.' | Select-Object -First 1
            if ([string]::IsNullOrEmpty($localEntityName)) { $localEntityName = $EntityName }
            $entity = @{
                "entity_type" = $localEntityName
                "properties"  = $obj | ConvertTo-PSFHashtable
            }
            [void]$entityList.Add($entity)
        }
    }
    end {
        return $entityList.ToArray()
    }
    # $apiCallParameter = @{
    #     EnableException        = $EnableException
    #     EnablePaging           = $EnablePaging
    #     Connection             = $Connection
    #     ConvertJsonAsHashtable = $false
    #     LoggingAction          = "Get-SMAXEntity"
    #     LoggingActionValues    = @($EntityName, $Properties,$Filter)
    #     method                 = "GET"
    #     Path                   = "/ems/$EntityName"
    #     URLParameter           = @{
    #         layout = $Properties | Join-String -Separator ','
    #     }
    # }
    # switch ($PsCmdlet.ParameterSetName) {
    #     'byEntityId'{
    #         $apiCallParameter.Path = $apiCallParameter.Path+"/$Id"
    #     }
    #     default{
    #         if (-not [string]::IsNullOrEmpty($Filter)) {
    #             $apiCallParameter.URLParameter.filter = $Filter
    #         }
    #     }
    # }
    # Write-PSFMessage "`$apiCallParameter=$($apiCallParameter|ConvertTo-Json)"
    # $result = Invoke-SMAXAPI @apiCallParameter | Where-Object { $_.properties}
    # foreach ($item in $result) {
    #     Add-Member -InputObject $item.properties -MemberType NoteProperty -Name related -Value $item.related_properties
    #     $item.properties.PSObject.TypeNames.Insert(0, "SMAX.$($item.entity_type)")
    # }
    # if($FlattenResult){
    #     return $result.properties|ConvertTo-SMAXFlatObject
    # }

    # return $result.properties

}