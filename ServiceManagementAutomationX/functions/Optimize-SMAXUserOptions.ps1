function Optimize-SMAXUserOptions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [string]$UserOptions
    )
    $optionsTable = ($UserOptions | ConvertFrom-Json -AsHashtable).complexTypeProperties.properties
    $UserOptionsType = $optionsTable.DynamicComplexTypeRefName_c
    $uoDef=Get-SMAXUserOption -Connection $Connection -Id $UserOptionsType
    $results=@{}
    foreach($key in $optionsTable.Keys){
        if ($optionsTable.$key -eq $UserOptionsType){
            Continue
        }
        $localizationKey = ($uoDef.userOptionsDescriptor.userOptionsPropertyDescriptors | Where-Object name -eq $key).localized_label_key

        $results.$key=[PSCustomObject]@{
            name = $key
            label = $uoDef.localizedLabels.$localizationKey
            value=$optionsTable.$key
        }
    }
    return $results
}