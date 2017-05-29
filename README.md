# AdvaniaGIT
Source Control Management for NAV C/AL


The installation is basically as follows:
                Install SQL Server 2016 Developers.  Enable TCP/IP port and set Maximum Memory options
                Install Dynamics NAV (2016 & 2017) with Developer option 
                Import valid NAV Development license into the master database
                Install GIT https://git-for-windows.github.io/ with default options
                Install SourceTree https://www.sourcetreeapp.com/ with default options
                Move customactions.xml to %LocalAppData%\Atlassian\SourceTree
                Start SourceTree and Clone https://github.com/gunnargestsson/nav2017
                As Admin in Powershell ISE
                               Enable Scripting
                               Run Scripts\Install-Modules
                               Run Scripts\Prepare-NAVEnvironment (need to repeat this after NAV installation/repair)
                               Edit Data\*.json to match your environment


Other things that I expect are as follows:
                Repository has setup.json file with settings
                Backups are stored on a FTP server or in the Backup folder
                Repositories that only store deltas must have access to 2017W1.txt file with CRONUS and that file should be in the Workspace folder
                

