function New-SMAXComment {
    <#
    .SYNOPSIS
        Creates a new comment object for Micro Focus SMAX.

    .DESCRIPTION
        The New-SMAXComment function is used to create a new comment object for use
        with Micro Focus SMAX. Comments are typically used to provide updates and
        communication within the SMAX system.

    .PARAMETER ActualInterface
        Specifies the actual interface through which the comment is made. Valid values
        are SAW, ESS, EMAIL, API, and SYSTEM. Default is "API".

    .PARAMETER Body
        Specifies the text content of the comment.

    .PARAMETER CommentFrom
        Specifies the source of the comment. Valid values are Agent, ExternalServiceDesk,
        SocialUser, System, User, and Vendor. Default is "System".

    .PARAMETER CommentTo
        Specifies the target of the comment. Valid values are Agent, ExternalServiceDesk,
        Stakeholder, User, and Vendor. Default is "Agent".

    .PARAMETER CompanyVendor
        Specifies the company or vendor related to the comment.

    .PARAMETER FunctionalPurpose
        Specifies the functional purpose of the comment. Valid values include Diagnosis,
        EndUserComment, FollowUp, ProvideInformation, RequestMoreInformation, Resolution,
        ResolutionActivity, and StatusUpdate.

    .PARAMETER Group
        Specifies the group associated with the comment.

    .PARAMETER IsSystem
        Indicates whether the comment is system-generated. Default is $false. If set
        to $true the comment will get readonly.

    .PARAMETER Media
        Specifies the media through which the comment is made. Valid values include Email,
        Fax, InstantMessage, InternalChat, Phone, UI, and Unknown. Default is "Unknown".

    .PARAMETER PersonParticipant
        Specifies the person or participant associated with the comment.

    .PARAMETER PrivacyType
        Specifies the privacy type of the comment. Valid values include INTERNAL, PUBLIC,
        and AGENTPUBLIC. Default is "PUBLIC".

    .PARAMETER Submitter
        Specifies the ID of the user who submitted the comment.

    .EXAMPLE
        $comment = New-SMAXComment -Body "This is a comment" -CommentFrom "User" -CommentTo "Agent"

        Description:
        Creates a new comment object with the specified content, sender, and target.

    .NOTES
        Date:   September 28, 2023
    #>
    [CmdletBinding()]
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
    if ($Submitter -gt 0) { $data.Submitter = @{UserId = $Submitter } }
    return $data
}