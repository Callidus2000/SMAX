function Add-SMAXAttachement {
    <#
    .SYNOPSIS
    Adds an attachment to a specified SMAX entity.

    .DESCRIPTION
    The Add-SMAXAttachement function uploads a file as an attachment to a
    specified entity in SMAX. It supports different entity types and handles
    existing attachments by modifying the complex type properties.

    .PARAMETER Connection
    Specifies the connection object to SMAX. If not provided, the last
    connection is used.

    .PARAMETER EnableException
    Indicates whether to enable exceptions. Default is $true.

    .PARAMETER EntityType
    Specifies the type of the entity to which the attachment will be added.

    .PARAMETER Id
    Specifies the ID of the entity.

    .PARAMETER Path
    Specifies the path to the file to be uploaded as an attachment.

    .PARAMETER AttachementProperty
    Specifies the property of the entity where the attachment will be stored.
    Tab Expansion included

    .EXAMPLE
    PS C:\> Add-SMAXAttachement -EntityType "Incident" -Id "12345" -Path
    "C:\file.txt" -AttachementProperty "IncidentAttachments"

    Adds the file "file.txt" as an attachment to the Incident entity with ID
    12345.

    #>
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
    $uploadData = Publish-SMAXAttachement -Connection $Connection -Path $Path
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
    Write-PSFMessage "New properties: $($newProperties |ConvertTo-Json -Compress)"
    $complexType.complexTypeProperties += [PSCustomObject]@{properties = $newProperties }
    Write-PSFMessage "complexType: $($complexType |ConvertTo-Json -Compress -Depth 5)"
    $entity.$AttachementProperty = $complexType |ConvertTo-Json -Compress -Depth 5
    $entity|Update-SMAXEntity -Connection $Connection -EntityType $EntityType
}