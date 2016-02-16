cVSSResources :: A DSC Resource for managing Windows Volume Shadow Copies
This repository contains the cVSSResources PowerShell module, containing Microsoft Windows PowerShell Desired State Configuration (DSC) resources to manage Volume Shadow Copies.

Background
This module contains two DSC Resources for managing Volume Shadow Copies.  The cVSS Resource configures VSS on a specified volume.  The cVSSTaskScheduler configures scheduled tasks to actually take the shadow copies.  When enabling VSS through a non-GUI method, the GUI will still show the Enabled button, but VSS will be enabled already along with whatever settings you specify.

Installation
To install the cVSSResources PowerShell module, download it and unzip it to $env:ProgramFiles\WindowsPowerShell\Modules.

Author
The author of this module is Jacob Benson. You can follow Jacob on Twitter @vhusker or on his website / blog at http://www.jacobbenson.com