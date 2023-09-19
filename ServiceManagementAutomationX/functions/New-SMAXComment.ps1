function New-SMAXComment {
    [CmdletBinding()        ]
    param (
        [ValidateSet("SAW", "ESS", "EMAIL", "API", "SYSTEM")]
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [string]$ActualInterface = "API",
        [parameter(mandatory = $true, ParameterSetName = "default")]
        [string]$Body,
        [ValidateSet("Agent", "ExternalServiceDesk", "SocialUser", "System", "User", "Vendor")]
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [string]$CommentFrom = "System",
        [ValidateSet("Agent", "ExternalServiceDesk", "Stakeholder", "User", "Vendor")]
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [string]$CommentTo = "Agent",
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [string]$CompanyVendor,
        [ValidateSet("Diagnosis", "EndUserComment", "FollowUp", "ProvideInformation", "RequestMoreInformation", "Resolution", "ResolutionActivity", "StatusUpdate")]
        [parameter(mandatory = $true, ParameterSetName = "default")]
        [string]$FunctionalPurpose,
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [string]$Group,
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [bool]$IsSystem = $false,
        [ValidateSet("Email", "Fax", "InstantMessage", "InternalChat", "Phone", "UI", "Unknown")]
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [string]$Media = "Unknown",
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [string]$PersonParticipant,
        [ValidateSet("INTERNAL", "PUBLIC", "AGENTPUBLIC")]
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [string]$PrivacyType = "PUBLIC",
        [parameter(mandatory = $false, ParameterSetName = "default")]
        [int]$Submitter
    )
    $data = @{
        'ActualInterface'   = "$ActualInterface"
        'AttachmentIds'     = @($AttachmentIds)
        'Body'              = "$Body"
        'CommentFrom'       = "$CommentFrom"
        'CommentTo'         = "$CommentTo"
        'CompanyVendor'     = "$CompanyVendor"
        'FunctionalPurpose' = "$FunctionalPurpose"
        'Group'             = "$Group"
        'IsSystem'          = $IsSystem
        'Media'             = "$Media"
        'PersonParticipant' = "$PersonParticipant"
        'PrivacyType'       = "$PrivacyType"
    }
    if ([string]::IsNullOrEmpty($data.AttachmentIds)) { $data.AttachmentIds = @() }
    if (-not [string]::IsNullOrEmpty($Submitter)) { $data.Submitter = @{UserId = $Submitter } }
    return $data
}