﻿@{
	# Script module or binary module file associated with this manifest
	RootModule = 'ServiceManagementAutomationX.psm1'

	# Version number of this module.
	ModuleVersion = '0.1.0'

	# ID used to uniquely identify this module
	GUID = '720c57b9-2d8f-4d49-a32a-9b634257c4f8'

	# Author of this module
	Author = 'Sascha Spiekermann'

	# Company or vendor of this module
	CompanyName = 'MyCompany'

	# Copyright statement for this module
	Copyright = 'Copyright (c) 2023 Sascha Spiekermann'

	# Description of the functionality provided by this module
	Description = 's'

	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.7.249' }
	)

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\ServiceManagementAutomationX.dll')

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\ServiceManagementAutomationX.Types.ps1xml')

	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\ServiceManagementAutomationX.Format.ps1xml')

	# Functions to export from this module
	FunctionsToExport = @(
		'Connect-SMAX'
		'ConvertTo-SMAXFlatObject'
		'Get-SMAXCurrentUser'
		'Get-SMAXEntityDescription'
		'Get-SMAXEntityList'
		'Get-SMAXEntity'
		'Get-SMAXEntityAssociation'
		'Get-SMAXLastConnection'
		'Get-SMAXRequest'
		'Get-SMAXTranslation'
		'Initialize-SMAXEntityModel'
		'Invoke-SMAXAPI'
		'New-SMAXEntity'
		'Update-SMAXEntity'
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
			# Tags = @()

			# A URL to the license for this module.
			# LicenseUri = ''

			# A URL to the main website for this project.
			# ProjectUri = ''

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			# ReleaseNotes = ''

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}