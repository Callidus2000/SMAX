function Add-SMAXEntity {
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
        $bulkParameter.Operation = 'Create'
    }
    process {
        $entityList += $InputObject
    }
    end {
        $bulkParameter.InputObject = $entityList
        Invoke-SMAXBulk @bulkParameter
    }
}