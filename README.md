# AdvaniaGIT

## Source Control Management for NAV C/AL and SourceTree
 
The installation is basically as follows:

* Install SQL Server 2016 Developers.  Enable TCP/IP port and set Maximum Memory options
* Install Dynamics NAV (2016 & 2017) with Developer option
* Import valid NAV Development license into the master database
* Install GIT <https://git-for-windows.github.io/> with default options
* Install SourceTree <https://www.sourcetreeapp.com/> with default options
* Start SourceTree and Clone/Pull <https://github.com/gunnargestsson/AdvaniaGIT>
* Right click Installation.ps1 (in your GIT folder) and select Run with PowerShell (as admin)

Repeate last two steps to update your installation

## Source Control Management using Docker for Visual Studio Code, both for AL and C/AL

* Install AdvaniaGIT VS Code Extension <https://marketplace.visualstudio.com/items?itemName=advaniagit.advaniagit>
* Start VS Code as Administrator 
* Execute Command Advania: Go!
* Confirm all defaults in the AdvaniaGIT Terminal
* Execute Comnand Advania: Import Microsoft NAV Container Helper Module
* Optionally execute Advania: Save Container Credentials

More information will be added to the Wiki <https://github.com/gunnargestsson/AdvaniaGIT/wiki>
Posts and examples found on Dynamics.is <https://dynamics.is/?tag=advaniagit>

## Other things that I expect are as follows:

* Repository has setup.json file with settings (see Demo folder)
* Backups are stored on a FTP server or in the Backup folder
* Repositories that only store deltas must have access to source file with CRONUS and that file should be stored on a FTP server or in the Source folder
