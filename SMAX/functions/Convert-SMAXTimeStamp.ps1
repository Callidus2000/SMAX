function Convert-SMAXTimeStamp {
    <#
    .SYNOPSIS
    Converts SMAX Timestamps to/from DateTime objects.

    .DESCRIPTION
    Converts SMAX Timestamps to/from DateTime objects.
    SMAX uses Unix Timestamps in milliseconds for every date/time property. This function
    helps with converting those to/from a more usable format.

    .PARAMETER FromTimeStamp
    The timestamp which should be converted

    .PARAMETER FromDateTime
    The datetime object to be converted

    .PARAMETER FromObject
    The object whose properties should be converted

    .PARAMETER ForceResult
    If used, the autodetection feature will not be used

    .EXAMPLE
    Convert-SMAXTimeStamp -FromTimeStamp 1695888000000

    Returns an object containing something like "Thursday, 28 September 2023 10:00:00"
    .EXAMPLE
    Convert-SMAXTimeStamp -FromDateTime (Get-Date)

    Returns the current timestamp

    .EXAMPLE
    $request=Get-SMAXEntity -EntityName Request -Properties CreateTime -Id 4711
    $request.CreateTime
    Tuesday, 10 January 2023 15:16:58
    Convert-SMAXTimeStamp -FromObject $request
    $request.CreateTime
    1673360218000

    Converts the propery CreateTime to/from the different formats. If you do not now the current state
    but the desired state use the -ForceResult parameter


    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(mandatory = $true, ParameterSetName = "FromTimeStamp")]
        $FromTimeStamp,
        [parameter(mandatory = $true, ParameterSetName = "FromDateTime")]
        [datetime]$FromDateTime,
        [parameter(mandatory = $true, ParameterSetName = "FromObject")]
        $FromObject,
        [parameter(mandatory = $false, ParameterSetName = "FromObject")]
    [ValidateSet('TimeStamp','DateTime')]
        $ForceResult
    )

    switch ($PSCmdlet.ParameterSetName) {
        FromTimeStamp {
            $FromTimeStampSeconds = [int64][math]::Truncate([double]($FromTimeStamp) / 1000)
            return Get-Date -UnixTimeSeconds $FromTimeStampSeconds
        }
        FromDateTime {
            ([long] (Get-Date -Date $FromDateTime -UFormat %s)) * 1000
        }
        FromObject {
            $hash = $FromObject | ConvertTo-PSFHashtable
            $dateTimeKeys = $hash.Keys | Where-Object { $_ -cmatch 'Date|Time' }
            foreach ($key in $dateTimeKeys) {
                $value = $FromObject.$key
                if ($value -match '^\d{12,16}$') {
                    if ($ForceResult -eq 'TimeStamp'){continue}
                    Write-PSFMessage "Converting Property $key from TimeStamp to DateTime"
                    $FromObject.$key=Convert-SMAXTimeStamp -FromTimeStamp $value
                }
                elseif ($value -is [datetime]) {
                    if ($ForceResult -eq 'DateTime') { continue }
                    Write-PSFMessage "Converting Property $key from DateTime to TimeStamp"
                    $FromObject.$key=Convert-SMAXTimeStamp -FromDateTime $value
                }
                else {
                    Write-PSFMessage "No idea how to handle the property $key with the value $value"
                }
            }
        }
    }
}