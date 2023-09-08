function Connect-SMAX {
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
	$connection=Connect-SMAX -Url $url -Credential $cred

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
		# [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("SMAX.url")]
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
	begin {
		if ($OldConnection) {
			Write-PSFMessage "Getting parameters from existing (mistyped) Connection object"
			throw "ToBeImplemented"
			# $Url=$OldConnection.ServerRoot
			# $Credential = $OldConnection.credential
			# if ($OldConnection.SkipCheck){
			# 	$connection.SkipCheck
			# }
			# $additionalParams = $OldConnection.forti
			# if ($OldConnection.forti.defaultADOM) {
			# 	$ADOM = $OldConnection.forti.defaultADOM
			# }
		}
		# else{
		# 	$additionalParams = @{
		# 		requestId       = 1
		# 		session         = $null
		# 		EnableException = $EnableException
		# 	}
		# }
	}
	end {
		$connection = Get-ARAHConnection -Url $Url -APISubPath "/rest/$Tenant"
		if ($SkipCheck) { $connection.SkipCheck = $SkipCheck }
		Add-Member -InputObject $connection -MemberType NoteProperty -Name "tenantId" -Value $Tenant
		Add-Member -InputObject $connection -MemberType NoteProperty -Name "psfConfPrefix" -Value ("ServiceManagementAutomationX."+(([System.Uri]$connection.WebServiceRoot).DnsSafeHost -replace '\.', '_')+".$Tenant")
		# $connection.credential = $Credential
		$connection.ContentType = "application/json;charset=UTF-8"
		$connection.authenticatedUser = $Credential.UserName
		$restParam = @{
			Uri         = "$($connection.ServerRoot)/auth/authentication-endpoint/authenticate/token"
			ContentType = $connection.ContentType
			Method      = "Post"
			Body        = (@{login = $Credential.UserName ; password = $Credential.GetNetworkCredential().Password } | ConvertTo-Json)
		}
		Write-PSFMessage "`$restParam=$($restParam|ConvertTo-Json -Compress)"
		# $token = Invoke-RestMethod -Uri "$($connection.WebServiceRoot)/auth/authentication-endpoint/authenticate/token" -ContentType $ContentType -Method Post -Body $Body -SkipCertificateCheck
		$token = Invoke-RestMethod @restParam

		# Invoke-PSFProtectedCommand -ActionString "Connect-SMAX.Connecting" -ActionStringValues $Url -Target $Url -ScriptBlock {
		# $result = Invoke-SMAXAPI @apiCallParameter -verbose
		Write-Host "`$token=$token"
		if ($null -eq $token) {
			Stop-PSFFunction -Message "No API Results" -EnableException $EnableException -FunctionName $functionName
		}
		$Cookie = New-Object System.Net.Cookie
		$Cookie.Name = "SMAX_AUTH_TOKEN" # Add the name of the cookie
		$Cookie.Value = $token # Add the value of the cookie
		$Cookie.Domain = ([System.Uri]$restParam.uri).DnsSafeHost
		$connection.WebSession.Cookies.add($Cookie)
		# Add-Member -InputObject $connection -MemberType ScriptMethod -Name "Refresh" -Value {
		# 	$functionName = "Connect-SMAX>Refresh"
		# 	Write-PSFMessage "Stelle Verbindung her zu $($this.ServerRoot)" -Target $this.ServerRoot -FunctionName $functionName

		# 	$apiCallParameter = @{
		# 		Connection          = $this
		# 		EnableException     = $this.forti.EnableException
		# 		method              = "exec"
		# 		Path                = "sys/login/user"
		# 		LoggingAction       = "Connect-SMAX"
		# 		LoggingActionValues = @($this.ServerRoot, $this.Credential.UserName)
		# 		Parameter           = @{
		# 			"data" = @{
		# 				"passwd" = $this.Credential.GetNetworkCredential().Password
		# 				"user"   = $this.Credential.UserName
		# 			}
		# 		}
		# 	}

		# 	# Invoke-PSFProtectedCommand -ActionString "Connect-SMAX.Connecting" -ActionStringValues $Url -Target $Url -ScriptBlock {
		# 	$result = Invoke-SMAXAPI @apiCallParameter
		# 	if ($null -eq $result) {
		# 		Stop-PSFFunction -Message "No API Results" -EnableException $EnableException -FunctionName $functionName
		# 	}
		# 	# } -PSCmdlet $PSCmdlet  -EnableException $EnableException
		# 	if (Test-PSFFunctionInterrupt) {
		# 		Write-PSFMessage "Test-PSFFunctionInterrupt" -FunctionName $functionName
		# 		return
		# 	}
		# 	if ($result.session) {
		# 		$this.forti.session = $result.session
		# 	}
		# }
		# switch ($PsCmdlet.ParameterSetName) {
		# 	'credential' {
		# 		$connection.Refresh()
		# 	}
		# 	'oldConnection' {}
		# }
		# if ($connection.forti.session) {
		# 	Write-PSFMessage -string "Connect-SMAX.Connected"
			Set-PSFConfig -Module 'ServiceManagementAutomationX' -Name 'LastConnection' -Value $connection -Description "Last known Connection" -AllowDelete
			return $connection
		# }
		# Write-PSFMessage -string "Connect-SMAX.NotConnected" -Level Warning
	}
}