function Optimize-SMAXUserOptions {
    <#
    .SYNOPSIS
        Optimizes user options data obtained from Micro Focus SMAX.

    .DESCRIPTION
        The Optimize-SMAXUserOptions function is used to optimize user options data
        obtained from Micro Focus SMAX. It takes the user options data as input and
        retrieves the corresponding user options definition to map and label the
        properties for better readability.

    .PARAMETER Connection
        Specifies the connection to the Micro Focus SMAX server. If not provided, it
        will use the last saved connection obtained using the Get-SMAXLastConnection
        function.

    .PARAMETER EnableException
        Indicates whether exceptions should be enabled. Default is $true.

    .PARAMETER UserOptions
        Specifies the user options data to optimize.

    .EXAMPLE
    $request=Get-SMAXEntity -EntityType Request -Properties UserOptions -Id 123
    $optimizedData = Optimize-SMAXUserOptions -Useroptions $request.useroptions

        Description:
        Retrieves user options data from SMAX Request 123 and optimizes it for better readability.

    .NOTES
        Date:   September 28, 2023
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [string]$UserOptions
    )
    $optionsTable = ($UserOptions | ConvertFrom-Json -AsHashtable).complexTypeProperties.properties
    $UserOptionsType = $optionsTable.DynamicComplexTypeRefName_c
    $uoDef = Get-SMAXUserOption -Connection $Connection -Id $UserOptionsType
    $results = [ordered]@{}
    foreach ($key in $uoDef.userOptionsDescriptor.userOptionsPropertyDescriptors.name) {
        if ($optionsTable.$key -eq $UserOptionsType) {
            Continue
        }
        $localizationKey = ($uoDef.userOptionsDescriptor.userOptionsPropertyDescriptors | Where-Object name -eq $key).localized_label_key

        $results.$key = [PSCustomObject]@{
            name  = $key
            label = $uoDef.localizedLabels.$localizationKey
            value = $optionsTable.$key
        }
    }
    return $results
}