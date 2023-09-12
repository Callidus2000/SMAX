function ConvertTo-SMAXFlatObject {
    [CmdletBinding()]
    param (
        [parameter(mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "default")]
        $InputObject,
        [string]$Prefix = $null,
       	[ValidateSet('HashTable', 'CustomObject')]
        [string]$ReturnMode = "CustomObject"
    )

    begin {

    }

    process {
        $result = @{}
        Write-PSFMessage "Prefix=$Prefix, InputObject=$($InputObject|ConvertTo-Json -Compress), result=$($result|ConvertTo-Json -Compress)"
        $hash = $InputObject | ConvertTo-Json -Depth 20|ConvertFrom-Json -AsHashtable
        foreach ($key in $hash.Keys) {
            if([string]::IsNullOrEmpty($Prefix)){
                $newKey = $key
            }else{
                $newKey = Join-String -InputObject $Prefix, $key -Separator '.'
            }
            if ($hash.$key -is [hashtable]) {
                Write-PSFMessage "Sub-Table für Key $key"
                $subHash = ConvertTo-SMAXFlatObject -Prefix $newKey -Input $hash.$key -ReturnMode HashTable
                Write-PSFMessage "subHash= $($subHash|ConvertTo-Json -Compress)"
                $result+= $subHash
            }
            else {
                $result.$newKey = $hash.$key
            }
        }
        if ($ReturnMode -eq 'HashTable') { return $result }
        return [PSCustomObject]$result
    }

    end {

    }
}