<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
***
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GPLv3 License][license-shield]][license-url]


<br />
<p align="center">
<!-- PROJECT LOGO
  <a href="https://github.com/Callidus2000/SMAX">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>
-->

  <h3 align="center">Service Management Automation X (SMAX)</h3>

  <p align="center">
    This Powershell Module is a wrapper for the API of the Service Management Automation X (SMAX) platform
    <br />
    <a href="https://github.com/Callidus2000/SMAX"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/Callidus2000/SMAX/issues">Report Bug</a>
    ·
    <a href="https://github.com/Callidus2000/SMAX/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#use-cases-or-why-was-the-module-developed">Use-Cases - Why was this module created?</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

## PowerShell Module for Service Management Automation X (SMAX)

This PowerShell module is designed to interact with and automate various operations related to the Service Management Automation X (SMAX) platform. Below is a summary of the module's capabilities and use cases:

### Connecting to SMAX:

- The module provides the ability to establish a connection to an SMAX instance using the `Connect-SMAX` function. Users can provide credentials, URLs, and other parameters to authenticate and establish the connection. Please ensure to run `Initialize-SMAXEntityModel -Persist` once for each tenant (and again after every change of the entity model).

### Entity Management:

- Users can create, update, and retrieve various entities within the SMAX platform. Entities can represent different types of data or records in the system. Functions like `Add-SMAXEntity`, `Update-SMAXEntity`, and others facilitate entity management.

### Association Management:

- Users can create and manage associations between different entities within SMAX using functions like `Add-SMAXAssociation`. This enables the establishment of relationships between different data elements.

### Comment and Collaboration:

- The module allows users to work with comments and collaboration features within SMAX. Functions like `Add-SMAXComment` and `Update-SMAXComment` enable interaction and communication within the platform.

### Metadata and Configuration:

- Users can retrieve metadata and configuration information from SMAX using functions like `Get-SMAXMetaEntityDescription` and `Get-SMAXMetaTranslation`. These functions provide insights into the structure and localization aspects of the SMAX environment.

### Bulk Operations:

- The module supports bulk operations for entities using functions like `Invoke-SMAXBulk`. This is useful for efficiently handling large datasets or performing batch operations.

### Error Handling:

- The module includes error handling and exception management capabilities to ensure robust and reliable automation workflows.

With these capabilities, this PowerShell module empowers users to automate and streamline their interactions with the SMAX platform, making it a valuable tool for administrators and developers working with SMAX instances.


The vendor's API documentation can be found at [https://docs.microfocus.com/](https://docs.microfocus.com/doc/SMAX/2023.05/EMSRestAPI).


### Built With

* [PSModuleDevelopment](https://github.com/PowershellFrameworkCollective/PSModuleDevelopment)
* [psframework](https://github.com/PowershellFrameworkCollective/psframework)
* [Advanced API Rest Helper](https://github.com/callidus2000/ARAH)




<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

- Powershell 7.x (Core) (If possible get the latest version)  
  Maybe it's working under 5.1, just did not test it
- A internal SMAX user with API access

### Installation

The releases are published in the Powershell Gallery, therefor it is quite simple:
  ```powershell
  Install-Module SMAX -Force -AllowClobber
  ```
The `AllowClobber` option is currently necessary because of an issue in the current PowerShellGet module. Hopefully it will not be needed in the future any more.

<!-- USAGE EXAMPLES -->
## Usage

The module is a wrapper for the Service Management Automation X (SMAX) API. For getting started take a look at the integrated help of the included functions. As inspiration you can take a look at the use-cases which led to the development of this module.

### Example Code
The following code should provide an idea how to use the module. Everything is highly dependable on your local entity model.
```Powershell
# Connect to SMAX (fictional tenant 123456)
$connection = Connect-SMAX -Credential $smaxCred -Url MyServer.MyCompany.com -verbose -TenantId "123456"

# Get all open Approvals as Task entities
$approvals = Get-SMAXEntity -Connection $connection -Entity "Task" -Filter "Status eq 'Open'" -verbose

# Enrich the approvals with info from the related requests
$enrichedApprovals = $approvals | ForEach-Object {
    $request = Get-SMAXEntity -Connection $connection -Entity "Request" -Id $_.RequestId -verbose
    [PSCustomObject]@{
        ApprovalId = $_.Id
        RequestId = $_.RequestId
        RequestTitle = $request.Title
        RequestDescription = $request.Description
        ApprovalStatus = $_.Status
    }
}

# Return it as PSCustomObjects
$enrichedApprovals
```
If you need an overview of the existing commands use

```powershell
# List available commands
Get-Command -Module SMAX
```
everything else is documented in the module itself.

### Tab Completion

After running `Initialize-SMAXEntityModel -Persist` the first time some Tab Completion magic is available. The module provides tab completion for various parameters and values, making it easier to use and reducing the chance of errors. To take advantage of this feature, simply press the `Tab` key while typing a command or parameter, and PowerShell will suggest possible completions based on the context. For example it provides the possible `-EntitiyType` values and the attributes (both requiring the correct case sensitivity).

<!-- ROADMAP -->
## Roadmap
New features will be added if any of my scripts need it ;-)

I cannot guarantee that no breaking change will occur as the development follows my internal DevOps need completely. Likewise I will not insert full documentation of all parameters as I don't have time for this copy&paste. Sorry. But major changes which classify as breaking changes will result in an increment of the major version. See [Changelog](SMAX\changelog.md) for information regarding breaking changes.

See the [open issues](https://github.com/Callidus2000/SMAX/issues) for a list of proposed features (and known issues).

If you need a special function feel free to contribute to the project.

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**. For more details please take a look at the [CONTRIBUTE](docs/CONTRIBUTING.md#Contributing-to-this-repository) document

Short stop:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## Limitations
* The module works on the tenant level as this is the only permission set I've been granted
* Maybe there are some inconsistencies in the docs, which may result in a mere copy/paste marathon from my other projects

<!-- LICENSE -->
## License

Distributed under the GNU GENERAL PUBLIC LICENSE version 3. See `LICENSE.md` for more information.



<!-- CONTACT -->
## Contact


Project Link: [https://github.com/Callidus2000/SMAX](https://github.com/Callidus2000/SMAX)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* [Friedrich Weinmann](https://github.com/FriedrichWeinmann) for his marvelous [PSModuleDevelopment](https://github.com/PowershellFrameworkCollective/PSModuleDevelopment) and [psframework](https://github.com/PowershellFrameworkCollective/psframework)





<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/Callidus2000/SMAX.svg?style=for-the-badge
[contributors-url]: https://github.com/Callidus2000/SMAX/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Callidus2000/SMAX.svg?style=for-the-badge
[forks-url]: https://github.com/Callidus2000/SMAX/network/members
[stars-shield]: https://img.shields.io/github/stars/Callidus2000/SMAX.svg?style=for-the-badge
[stars-url]: https://github.com/Callidus2000/SMAX/stargazers
[issues-shield]: https://img.shields.io/github/issues/Callidus2000/SMAX.svg?style=for-the-badge
[issues-url]: https://github.com/Callidus2000/SMAX/issues
[license-shield]: https://img.shields.io/github/license/Callidus2000/SMAX.svg?style=for-the-badge
[license-url]: https://github.com/Callidus2000/SMAX/blob/master/LICENSE
````

