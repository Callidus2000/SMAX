@{
	# Script module or binary module file associated with this manifest
	RootModule = 'SMAX.psm1'

	# Version number of this module.
	ModuleVersion = '1.0.0'

	# ID used to uniquely identify this module
	GUID = '720c57b9-2d8f-4d49-a32a-9b634257c4f8'

	# Author of this module
	Author = 'Sascha Spiekermann'

	# Company or vendor of this module
	CompanyName = 'MyCompany'

	# Copyright statement for this module
	Copyright = 'Copyright (c) 2023 Sascha Spiekermann'

	# Description of the functionality provided by this module
	Description = 'PowerShell Module for Service Management Automation X (SMAX)'

	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.1'

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.9.310' }
		@{ ModuleName='ARAH'; ModuleVersion='1.4.0' }
	)

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\SMAX.dll')

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\SMAX.Types.ps1xml')

	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\SMAX.Format.ps1xml')

	# Functions to export from this module
	FunctionsToExport = @(
		'Add-SMAXAssociation'
		'Add-SMAXComment'
		'Add-SMAXEntity'
		'Connect-SMAX'
		'Convert-SMAXTimeStamp'
		'ConvertTo-SMAXFlatObject'
		'Get-SMAXAttachement'
		'Get-SMAXComment'
		'Get-SMAXConfPrefix'
		'Get-SMAXCurrentUser'
		'Get-SMAXEntity'
		'Get-SMAXEntityAssociation'
		'Get-SMAXEntityDescription'
		'Get-SMAXEntityList'
		'Get-SMAXLastConnection'
		'Get-SMAXRequest'
		'Get-SMAXUserOption'
		'Initialize-SMAXEntityModel'
		'Invoke-SMAXAPI'
		'New-SMAXComment'
		'New-SMAXEntity'
		'Optimize-SMAXUserOptions'
		'Remove-SMAXAssociation'
		'Remove-SMAXComment'
		'Update-SMAXComment'
		'Update-SMAXEntity'
		# 'Get-SMAXMetaEntityDescription'
		# 'Get-SMAXMetaTranslation'
	)

	# Cmdlets to export from this module
	CmdletsToExport = ''

	# Variables to export from this module
	VariablesToExport = ''

	# Aliases to export from this module
	AliasesToExport = ''

	# List of all modules packaged with this module
	ModuleList = @()

	# List of all files packaged with this module
	FileList = @()

	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		#Support for PowerShellGet galleries.
		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('SMAX','ServiceManagementAutomationX')

			# A URL to thehttps://raw.githubusercontent.com/Callidus2000/SMAX/main/LICENSE license for this module.
			LicenseUri = 'https://raw.githubusercontent.com/Callidus2000/SMAX/main/LICENSE'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/Callidus2000/SMAX/'

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			# ReleaseNotes = ''

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}