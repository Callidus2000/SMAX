function Add-SMAXAttachement {

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [bool]$EnableException = $true,
        [parameter(mandatory = $false, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        $Id,
        [parameter(mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "byEntityId")]
        [string]$Path,
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.AttachementProperty")]
        [string]$AttachementProperty
    )
    if (-not (Test-Path -Path $Path)) {
        Stop-PSFFunction -Message "File '$Path' does not exist"
        return
    }
    $entity = Get-SMAXEntity -EntityType $EntityType -Id $Id -Properties Id, $AttachementProperty
    if ($null -eq $entity) {
        Stop-PSFFunction -Message "Entity #$Id of Type $EntityType does not exist"
        return
    }
    if ($entity.$AttachementProperty) {
        Write-PSFMessage "Modifying existing ComplexType"
        $complexType = $entity.$AttachementProperty | ConvertFrom-Json -AsHashtable
    }
    else {
        $complexType = @{"complexTypeProperties" = @() }
    }
    $uploadData = Publish-SMAXAttachement -Connection $Connection -Path $Path -verbose
    Write-PSFMessage "Metadata of upload: $($uploadData |ConvertTo-Json -Compress)"
    if ($null -eq $uploadData -or [string]::IsNullOrEmpty( $uploadData.guid)) {
        Stop-PSFFunction -Message "Error while uploading the attachement"
        return
    }
    $newProperties = ($uploadData | Select-PSFObject -Property @(
            "guid as id"
            "contentType as mime_type"
            "name as file_name"
            @{name = "file_extension"; expression = { [System.IO.Path]::GetExtension($_.name).TrimStart('.') }}
            "contentLength as size"
            "creator"
            "lastModified as LastUpdateTime"
        )
    )
    # id - the guid returned in the attachment response
    # file_name - the name returned in the attachment response
    # file_extension - the extension from the name property above (.txt for example)
    # size - the contentLength from the attachment response
    # mime_type - the contentType from the attachment response
    # Creator - the user that added the attachment, this should be the current login id/email
    Write-PSFMessage "New properties: $($newProperties |ConvertTo-Json -Compress)"
    $complexType.complexTypeProperties += [PSCustomObject]@{properties = $newProperties }
    Write-PSFMessage "complexType: $($complexType |ConvertTo-Json -Compress -Depth 5)"
    $entity.$AttachementProperty = $complexType |ConvertTo-Json -Compress -Depth 5
    $entity|Update-SMAXEntity -Connection $Connection -EntityType $EntityType
    # @{
    #     "properties": {
    #         "IsHidden": false,
    #         "size": 20,
    #         "mime_type": "text/plain",
    #         "LastUpdateTime": 1740564048159,
    #         "file_name": "Dummy.txt",
    #         "file_extension": "txt",
    #         "id": "f7cf9797-fc4f-4eb9-82ac-6ecfe3139f3f",
    #         "Creator": "1001683"
    #     }
    # }
}