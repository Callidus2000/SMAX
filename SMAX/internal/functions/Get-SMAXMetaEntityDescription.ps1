function Get-SMAXMetaEntityDescription {
    <#
    .SYNOPSIS
    Retrieves metadata descriptions for entities in the Service Management Automation X (SMAX) platform.

    .DESCRIPTION
    The Get-SMAXMetaEntityDescription function allows you to retrieve metadata descriptions for SMAX entities.
    You can specify the entity name and provide a connection.

    .PARAMETER Connection
    Specifies the SMAX connection to use. If not provided, it uses the last established connection.

    .PARAMETER EntityType
    Specifies the name of the entity for which metadata descriptions are retrieved.

    .PARAMETER EnableException
    Indicates whether exceptions should be enabled. By default, exceptions are enabled.

    .EXAMPLE
    PS C:\> Get-SMAXMetaEntityDescription -Connection $conn -EntityType "Incident"

    This example retrieves metadata descriptions for the "Incident" entity in the SMAX platform.

    .NOTES
    File Name      : Get-SMAXMetaEntityDescription.ps1

    #>
    param (
        [parameter(Mandatory = $false)]
        $Connection = (Get-SMAXLastConnection),
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.EntityTypes")]
        [string]$EntityType,
        [bool]$EnableException = $true
    )
        $apiCallParameter = @{
            EnableException = $EnableException
            Connection      = $Connection
            LoggingAction   = "Get-SMAXMetaEntityDescription"
            method          = "GET"
            Path            = "/metadata/ui/entity-descriptors"
        }
        $result = Invoke-SMAXAPI @apiCallParameter
        return $result.entity_descriptors | Where-Object domain -NotMatch 'sample'
}