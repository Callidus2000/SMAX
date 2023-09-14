﻿function Update-SMAXEntity {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityNames")]
        [string]$EntityName,
        [parameter(mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "byEntityId")]
        [object[]]$InputObject
    )
    begin {
        $entityList = @()
        $bulkParameter = $PSBoundParameters | ConvertTo-PSFHashtable -Exclude LoggingActionValues, RevisionNote, LoggingAction, InputObject
        $bulkParameter.Operation = 'Update'
        # $InputObject | ForEach-Object { "BeginUpdate $($_.Id), Typenames= $($_.psobject.TypeNames -join ',')" | Out-Host }
        # Write-PSFMessage "BeginUpdate `$InputObject.Gettype(): $($InputObject.GetType())"
    }
    process {

        $entityList += $InputObject
    }
    end {
        $bulkParameter.InputObject = $entityList
        # $bulkParameter.InputObject | ForEach-Object { "EndUpdate $($_.Id), Typenames= $($_.psobject.TypeNames -join ',')" | Out-Host }
        Invoke-SMAXBulk @bulkParameter
    }
}