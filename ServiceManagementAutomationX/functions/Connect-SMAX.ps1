function Connect-SMAX {
	<#
	.SYNOPSIS
	Establishes a connection to the Service Management Automation X (SMAX) platform.

	.DESCRIPTION
	The Connect-SMAX function allows you to establish a connection to the SMAX platform
	by providing the URL, tenant, and credentials. It also supports reusing an existing
	SMAX connection.

	.PARAMETER Url
	Specifies the URL of the SMAX instance to connect to.

	.PARAMETER Tenant
	Specifies the tenant ID for the SMAX instance.

	.PARAMETER Credential
	Specifies the credentials used for authentication.

	.PARAMETER OldConnection
	Specifies an existing SMAX connection to reuse.

	.PARAMETER SkipCheck
	Specifies checks to skip during the connection process, such as certificate checks,
	HTTP error checks, or header validation checks.

	.PARAMETER EnableException
	Indicates whether exceptions should be enabled. By default, exceptions are enabled.

	.EXAMPLE
	$connection=Connect-SMAX -Url $url -Credential $cred -Tenant 888220

	Connect directly with a Credential-Object
	.EXAMPLE
	$connection=Connect-SMAX -Url $url -Credential $cred
	$connection=Export-Clixml -Path ".\connection.xml"
	$importedConnection=Import-Clixml -Path ".\connection.xml"
	$secondConnection=Connect-SMAX -OldConnection $importedConnection

	Connect with the information from a serialized object

	.NOTES
	#>
	<#
	.SYNOPSIS
	Creates a new Connection Object to a SMAX instance.

	.DESCRIPTION
	Creates a new Connection Object to a SMAX instance.

	.PARAMETER Credential
	Credential-Object for direct login.

	.PARAMETER Tenant
	The Tenant ID for the connection

	.PARAMETER Url
	The server root URL.

	.PARAMETER OldConnection
	An old connection to be revived. This can be obtained e.g. by Export-Clixml/Import-Clixml.

    .PARAMETER SkipCheck
    Array of checks which should be skipped while using Invoke-WebRequest.
    Possible Values 'CertificateCheck', 'HttpErrorCheck', 'HeaderValidation'.
    If neccessary by default for the connection set $connection.SkipCheck

	.PARAMETER EnableException
	Should Exceptions been thrown?

	.EXAMPLE
	$connection=Connect-SMAX -Url $url -Credential $cred -Tenant 888220

	Connect directly with a Credential-Object
	.EXAMPLE
	$connection=Connect-SMAX -Url $url -Credential $cred
	$connection=Export-Clixml -Path ".\connection.xml"
	$importedConnection=Import-Clixml -Path ".\connection.xml"
	$secondConnection=Connect-SMAX -OldConnection $importedConnection

	Connect with the information from a serialized object

	.NOTES
	#>

	# [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
	# [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	[CmdletBinding(DefaultParameterSetName = "credential")]
	Param (
		[parameter(mandatory = $true, ParameterSetName = "credential")]
		[string]$Url,
		[parameter(mandatory = $true, ParameterSetName = "credential")]
		[string]$Tenant,
		[parameter(mandatory = $true, ParameterSetName = "credential")]
		[pscredential]$Credential,
		[parameter(mandatory = $true, ParameterSetName = "oldConnection")]
		$OldConnection,
		[ValidateSet('CertificateCheck', 'HttpErrorCheck', 'HeaderValidation')]
		[String[]]$SkipCheck,
		[bool]$EnableException = $true
	)
	if ($OldConnection) {
		Write-PSFMessage "Getting parameters from existing (mistyped) Connection object"
		$connection = Get-ARAHConnection -Url $OldConnection.ServerRoot -APISubPath "/rest/$($OldConnection.tenantId)"
		if ($SkipCheck) { $connection.SkipCheck = $SkipCheck }
		Add-Member -InputObject $connection -MemberType NoteProperty -Name "tenantId" -Value $OldConnection.tenantId
		Add-Member -InputObject $connection -MemberType NoteProperty -Name "psfConfPrefix" -Value $OldConnection.psfConfPrefix
		Set-PSFConfig -Module 'ServiceManagementAutomationX' -Name 'lastConfPrefix' -Value $OldConnection.psfConfPrefix -AllowDelete -Validation string -Description "The last connection prefix; needed for TEPP if no connection available" -PassThru | Register-PSFConfig -Scope UserDefault

		$token = $OldConnection.authCookie.Value
		$connection.ContentType = "application/json;charset=UTF-8"
		$connection.authenticatedUser = $OldConnection.authenticatedUser
		$Cookie = New-Object System.Net.Cookie
		$Cookie.Name = "SMAX_AUTH_TOKEN" # Add the name of the cookie
		$Cookie.Value = $token # Add the value of the cookie
		$Cookie.Domain = ([System.Uri]$OldConnection.ServerRoot).DnsSafeHost
		Add-Member -InputObject $connection -MemberType NoteProperty -Name "authCookie" -Value $Cookie
		Set-PSFConfig -Module 'ServiceManagementAutomationX' -Name 'LastConnection' -Value $connection -Description "Last known Connection" -AllowDelete
		return $connection
	}
	$connection = Get-ARAHConnection -Url $Url -APISubPath "/rest/$Tenant"
	if ($SkipCheck) { $connection.SkipCheck = $SkipCheck }
	Add-Member -InputObject $connection -MemberType NoteProperty -Name "tenantId" -Value $Tenant
	$psfConfPrefix = ("ServiceManagementAutomationX." + (([System.Uri]$connection.WebServiceRoot).DnsSafeHost -replace '\.', '_') + ".$Tenant")
	Add-Member -InputObject $connection -MemberType NoteProperty -Name "psfConfPrefix" -Value $psfConfPrefix
	Set-PSFConfig -Module 'ServiceManagementAutomationX' -Name 'lastConfPrefix' -Value $psfConfPrefix -AllowDelete -Validation string -Description "The last connection prefix; needed for TEPP if no connection available" -PassThru | Register-PSFConfig -Scope UserDefault

	$connection.ContentType = "application/json;charset=UTF-8"
	$connection.authenticatedUser = $Credential.UserName
	$restParam = @{
		Uri         = "$($connection.ServerRoot)/auth/authentication-endpoint/authenticate/token"
		ContentType = $connection.ContentType
		Method      = "Post"
		Body        = (@{login = $Credential.UserName ; password = $Credential.GetNetworkCredential().Password } | ConvertTo-Json)
	}
	$token = Invoke-RestMethod @restParam

	if ($null -eq $token) {
		Stop-PSFFunction -Message "No API Results" -EnableException $EnableException -FunctionName $functionName
	}
	$Cookie = New-Object System.Net.Cookie
	$Cookie.Name = "SMAX_AUTH_TOKEN" # Add the name of the cookie
	$Cookie.Value = $token # Add the value of the cookie
	$Cookie.Domain = ([System.Uri]$restParam.uri).DnsSafeHost
	Add-Member -InputObject $connection -MemberType NoteProperty -Name "authCookie" -Value $Cookie

	Set-PSFConfig -Module 'ServiceManagementAutomationX' -Name 'LastConnection' -Value $connection -Description "Last known Connection" -AllowDelete
	return $connection
}