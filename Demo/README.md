# AdvaniaGIT
Source Control Management for NAV C/AL

Here are some Demo setup.json files


{
# Unique ID for the branch.  Created with New-Guid in PowerShell
  "branchId": "479e77f3-031a-49fe-bb6a-314464c6a9a8",  
# Build version for NAV  
  "navVersion": "10.0.15052.0",
# Basic NAV Solution.  Used to locate a backup if backup is not found for the project name
  "navSolution": "W1",
# Name for the NAV backup.  Will in most cases match the branch name
  "projectName": "GLSOURCENAMES",
# Branch name for the base solution.  Will be used to create Deltas   
  "baseBranch": "master",
# If false only the Deltas will be stored in the repository
  "storeAllObjects": "false",
# New IDs in the DEV will start with this number  
  "uidOffset": "70009200",  
# Where to find the DEV license file  
  "licenseFile": "Kappi.flf",
# Unused
  "versionList": "GLSN10.0",
# Unused  
  "objectProperties": "true",
# Unused  
  "datetimeCulture": "is-IS",
# Will add the aid=fin option to the web client
  "targetPlatform": "Dynamics365",
# Settings for the Extension  
  "appId": "479e77f3-031a-49fe-bb6a-314464c6a9a8",
  "appName": "G/L Source Names",
  "appPublisher": "Objects4NAV",
  "appVersion": "1.0.0.1",
  "appCompatibilityId": "",
  "appManifestName": "G/L Source Names",
  "appManifestDescription": "G/L Source Names adds the source name to the G/L Entries page.  Source Name is the customer in sales transaction and the vendor in purchase transactions", 
  "appBriefDescription": "Source Names in G/L Entries",
  "appPrivacyStatement": "http://objects4nav.com/privacy",
  "appEula": "http://objects4nav.com/terms",
  "appHelp": "http://objects4nav.com/glsourcenames",
  "appUrl": "http://objects4nav.com",
  "appIcon": "Logo250x250",  
  "appDependencies":
    [
  
    ],
  "appPrerequisites":
    [
  
    ],
  "permissionSets":
    [
  		{"id": "G/L-SOURCE NAMES",    "description": "Read G/L Source Names"},
  		{"id": "G/L-SOURCE NAMES, E", "description": "Update G/L Source Names"},
  		{"id": "G/L-SOURCE NAMES, S", "description": "Setup G/L Source Names"}
  	],
  "webServices":
    [
    
    ],
  "dotnetAddins":
    [
  
    ],
  "tableDatas":
    [
   
    ]
}

{
  "branchId": "bc2f9d07-88a6-49ab-b50a-da21c72e672e",
  "navSolution": "ADIS",
  "storeAllObjects": "true",
  "licenseFile": "Advania.flf",
  "navVersion": "9.0.48316.0",
  "projectName": "Kappi_ehf",
  "baseBranch": "ADIS",
# When building the solution from base branch the Deltas form the following branches are also used  
  "deltaBranchList": "PUNCH,STORE,ExternalAttachments,ItemHistory",
  "uidOffset": "50000",  
  "objectProperties": "true",
  "datetimeCulture": "is-IS"
}


