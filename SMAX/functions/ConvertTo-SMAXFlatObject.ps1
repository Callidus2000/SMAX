function ConvertTo-SMAXFlatObject {
    <#
    .SYNOPSIS
    Converts a multi-level HashMap/Object to a single level HashMap.

    .DESCRIPTION
    Converts a multi-level HashMap/Object to a single level HashMap.

    .PARAMETER InputObject
    The original HashMap/Object

    .PARAMETER Prefix
    Should the keys get a prefix?

    .PARAMETER ReturnMode
    Either 'HashTable' or 'CustomObject' (Default)

    .EXAMPLE
    @{
       hubba="Bubba"
       one=@{
           second=@{
               third="Nr3"
           }
           secondHalf="Life"
       }
    }| ConvertTo-SMAXFlatObject | ConvertTo-Json -WarningAction SilentlyContinue

    Returns
    {
    "one.secondHalf": "Life",
    "one.second.third": "Nr3",
    "hubba": "Bubba"
    }

    .NOTES
    General notes
    #>
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
        Write-PSFMessage "Prefix=$Prefix, InputObject=$($InputObject|ConvertTo-Json -WarningAction SilentlyContinue -Compress), result=$($result|ConvertTo-Json -WarningAction SilentlyContinue -Compress)"
        $hash = $InputObject | ConvertTo-Json -WarningAction SilentlyContinue -Depth 20|ConvertFrom-Json -AsHashtable
        foreach ($key in $hash.Keys) {
            if([string]::IsNullOrEmpty($Prefix)){
                $newKey = $key
            }else{
                $newKey = Join-String -InputObject $Prefix, $key -Separator '.'
            }
            if ($hash.$key -is [hashtable]) {
                Write-PSFMessage "Sub-Table für Key $key"
                $subHash = ConvertTo-SMAXFlatObject -Prefix $newKey -Input $hash.$key -ReturnMode HashTable
                Write-PSFMessage "subHash= $($subHash|ConvertTo-Json -WarningAction SilentlyContinue -Compress)"
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