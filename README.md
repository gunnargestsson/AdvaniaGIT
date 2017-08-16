# AdvaniaGIT

## Source Control Management for NAV C/AL
 
The installation is basically as follows:

* Install SQL Server 2016 Developers.  Enable TCP/IP port and set Maximum Memory options
* Install Dynamics NAV (2016 & 2017) with Developer option
* Import valid NAV Development license into the master database
* Install GIT <https://git-for-windows.github.io/> with default options
* Install SourceTree <https://www.sourcetreeapp.com/> with default options
* Start SourceTree and Clone/Pull <https://github.com/gunnargestsson/AdvaniaGIT>
* Right click SetupLocalCopy.ps1 (in your GIT folder) and select Run with PowerShell

Repeate last two steps to update your installation

More information will be added to the Wiki <https://github.com/gunnargestsson/AdvaniaGIT/wiki>

## Other things that I expect are as follows:

* Repository has setup.json file with settings (see Demo folder)
* Backups are stored on a FTP server or in the Backup folder
* Repositories that only store deltas must have access to source file with CRONUS and that file should be stored on a FTP server or in the Source folder
