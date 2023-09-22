function Convert-SMAXTimeStamp {
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