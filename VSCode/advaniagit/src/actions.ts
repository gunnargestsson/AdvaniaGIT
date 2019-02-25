'use strict';
import * as vscode from "vscode";
import * as terminal from './terminal';
import * as path from "path";
import * as fs from "fs";

export function StartAdvaniaGITInstallation() {
    terminal.PSTerminal.sendText(`Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gunnargestsson/AdvaniaGIT/master/Scripts/Install-AdvaniaGIT.ps1" -OutFile "$($env:TEMP)\\Install-AdvaniaGIT.ps1" -ErrorAction Stop`);
    terminal.PSTerminal.sendText(`& "$($env:TEMP)\\Install-AdvaniaGIT.ps1"`);
}

export function StartAdvaniaGITContainerHostDebug() {
    terminal.PSTerminal.sendText(`Invoke-WebRequest https://aka.ms/Debug-ContainerHost.ps1 -UseBasicParsing | Invoke-Expression`);
}

export function BuildDeltasInGIT(Repository) {
    StartAction(Repository,`Build-DeltasInGIT.ps1`);
}
export function BuildDeltasFromSourceInGIT(Repository) {
    StartAction(Repository,`Build-DeltasFromSourceInGIT.ps1`);
}
export function BuildNavEnvironment(Repository) {
    StartAction(Repository,`Build-NavEnvironment.ps1`);
}
export function BuildNavEnvironmentFromGIT(Repository) {
    StartAction(Repository,`Build-NavEnvironmentFromGIT.ps1`);
}
export function BuildNAVNewSyntaxDeltasInGIT(Repository) {
    StartAction(Repository,`Build-NAVNewSyntaxDeltasInGIT.ps1`);
}
export function BuildSource(Repository) {
    StartAction(Repository,`Build-Source.ps1`);
}
export function BuildTarget(Repository) {
    StartAction(Repository,`Build-Target.ps1`);
}
export function CheckNAVEnvironment(Repository) {
    StartAction(Repository,`Check-NAVEnvironment.ps1`);
}
export function ClearNAVCommentSection(Repository) {
    StartAction(Repository,`Clear-NAVCommentSection.ps1`);
}
export function ConvertNAVNewSyntaxDeltasToAL(Repository) {
    StartAction(Repository,`Convert-NAVNewSyntaxDeltasToAL.ps1`);
}
export function ConvertNAVNewSyntaxObjectsToAL(Repository) {
    StartAction(Repository,`Convert-NAVNewSyntaxObjectsToAL.ps1`);
}
export function ConvertNAVNewSyntaxTestObjectsToAL(Repository) {
    StartAction(Repository,`Convert-NAVNewSyntaxTestsToAL.ps1`);
}
export function CreateCodeDeltas(Repository) {
    StartAction(Repository,`Create-CodeDeltas.ps1`);
}
export function CreateDeltas(Repository) {
    StartAction(Repository,`Create-Deltas.ps1`);
}
export function CreateNavBackup(Repository) {
    StartAction(Repository,`Create-NavBackup.ps1`);
}
export function CreateNavBackupOnFtpServer(Repository) {
    StartAction(Repository,`Create-NavBackupOnFtpServer.ps1`);
}
export function CreateNavBacpac(Repository) {
    StartAction(Repository,`Create-NavBacpac.ps1`);
}
export function CreateReverseDeltas(Repository) {
    StartAction(Repository,`Create-ReverseDeltas.ps1`);
}
export function CreateXlfFromCALTranslateFile(Repository) {
    StartAction(Repository,`Create-XlfFromCALTranslate.ps1`);
}
export function UpdateUsageCategory(Repository) {
    StartAction(Repository,`Create-UsageCategory.ps1`);
}
export function BuildNAVSymbolReferences(Repository) {
    StartAction(Repository,`Build-NAVSymbolReferences.ps1`);
}
export function SignAppPackage(Repository) {
    StartAction(Repository,`Sign-AppPackage.ps1`);
}
export function StartNAVAppDataUpgrade(Repository) {
    StartAction(Repository,`Start-NAVAppDataUpgrade.ps1`);
}
export function DummyAction(Repository) {
    StartAction(Repository,`Dummy-Action.ps1`);
}
export function ExportGITtoModified(Repository) {
    StartAction(Repository,`export-GITtoModified.ps1`);
}
export function ExportGITtoNAVNewSyntaxModified(Repository) {
    StartAction(Repository,`export-GITtoNAVNewSyntaxModified.ps1`);
}
export function ExportGITtoNAVNewSyntaxSource(Repository) {
    StartAction(Repository,`export-GITtoNAVNewSyntaxSource.ps1`);
}
export function ExportGITtoSource(Repository) {
    StartAction(Repository,`export-GITtoSource.ps1`);
}
export function ExportNavFob(Repository) {
    StartAction(Repository,`export-NavFob.ps1`);
}
export function ExportPermissionSets(Repository) {
    StartAction(Repository,`export-PermissionSets.ps1`);
}
export function ImportNavFob(Repository) {
    StartAction(Repository,`Import-NavFob.ps1`);
}
export function ImportRemoteNavFob(Repository) {
    StartAction(Repository,`Import-RemoteNavFob.ps1`);
}
export function ImportFromGITtoNAV(Repository) {
    StartAction(Repository,`ImportFrom-GITtoNAV.ps1`);
}
export function ImportFromModifiedNAVtoGIT(Repository) {
    StartAction(Repository,`ImportFrom-ModifiedNAVtoGIT.ps1`);
}
export function ImportFromModifiedNewSyntaxNAVtoGIT(Repository) {
    StartAction(Repository,`ImportFrom-ModifiedNewSyntaxNAVtoGIT.ps1`);
}
export function ImportFromNAVNewSyntaxToGIT(Repository) {
    StartAction(Repository,`ImportFrom-NAVNewSyntaxToGIT.ps1`);
}
export function ImportFromNAVtoGIT(Repository) {
    StartAction(Repository,`ImportFrom-NAVtoGIT.ps1`);
}
export function ImportFromNAVtoTarget(Repository) {
    StartAction(Repository,`ImportFrom-NAVtoTarget.ps1`);
}
export function ImportFromTargetToGIT(Repository) {
    StartAction(Repository,`ImportFrom-TargetToGIT.ps1`);
}
export function ImportFromTestObjectsToNAV(Repository) {
    StartAction(Repository,`ImportFrom-TestObjectsToNAV.ps1`);
}
export function ImportFromTestLibrariesToNAV(Repository) {
    StartAction(Repository,`ImportFrom-StandardTestLibrariesToNAV.ps1`);
}
export function ManageDatabases(Repository) {
    StartAction(Repository,`Manage-Databases.ps1`);
}
export function ManageInstances(Repository) {
    StartAction(Repository,`Manage-Instances.ps1`);
}
export function ManageContainers(Repository) {
    StartAction(Repository,`Manage-Containers.ps1`);
}
export function MergeDeltas(Repository) {
    StartAction(Repository,`Merge-Deltas.ps1`);
}
export function PrepareNAVEnvironment(Repository) {
    StartAction(Repository,`Prepare-NAVEnvironment.ps1`);
}
export function PrepareNAVUnitTest(Repository) {
    StartAction(Repository,`Prepare-NAVUnitTest.ps1`);
}
export function RemoveNavEnvironment(Repository) {
    vscode.window.showInputBox({
        placeHolder: "<Confirm environment removal by pressing Enter>",
        prompt: "Environment Removal will delete the SQL Database and the Container (Press 'Enter' to confirm or 'Escape' to cancel)" }
    ).then((value: string) => {
        if (value == ``) {
            StartAction(Repository,`Remove-NavEnvironment.ps1`);               
        } else {
            vscode.window.showInformationMessage('Branch removal canceled')
        }
    })
}
export function ReplaceGITwithTarget(Repository) {
    StartAction(Repository,`Replace-GITwithTarget.ps1`);
}
export function SaveTestResults(Repository) {
    StartAction(Repository,`Save-TestResults.ps1`);
}
export function SaveTestResultsCsv(Repository) {
    StartAction(Repository,`Save-TestResultsCsv.ps1`);
}
export function StartClient(Repository) {
    StartAction(Repository,`Start-Client.ps1`);
}
export function StartCompile(Repository) {
    StartAction(Repository,`Start-Compile.ps1`);
}
export function StartDebugger(Repository) {
    StartAction(Repository,`Start-Debugger.ps1`);
}
export function StartFinSql(Repository) {
    StartAction(Repository,`Start-FinSql.ps1`);
}
export function StartFullTestsExecution(Repository) {
    StartAction(Repository,`Start-FullTestsExecution.ps1`);
}
export function StartModifiedObjectsTestsExecution(Repository) {
    StartAction(Repository,`Start-ModifiedObjectsTestsExecution.ps1`);
}
export function StartFailedTestsExecution(Repository) {
    StartAction(Repository,`Start-FailedTestsExecution.ps1`);
}
export function StartVSCode(Repository) {
    StartAction(Repository,`Start-VSCode.ps1`);
}
export function StartVSCodeOnCurrentBranch(Repository) {
    StartAction(Repository,`Start-VSCodeOnCurrentBranch.ps1`);
}
export function StartWebClient(Repository) {
    StartAction(Repository,`Start-WebClient.ps1`);
}
export function StopNAVServices(Repository) {
    StartAction(Repository,`Stop-NAVServices.ps1`);
}
export function SyncRemoteNAVInstance(Repository) {
    StartAction(Repository,`Sync-RemoteNAVInstance.ps1`);
}
export function UpdateNAVSource(Repository) {
    StartAction(Repository,`Update-NAVSource.ps1`);
}
export function UpgradeNAVInstallation(Repository) {
    StartAction(Repository,`Upgrade-NAVInstallation.ps1`);
}
export function UploadNAVDatabaseBackup(Repository) {
    StartAction(Repository,`Upload-NAVDatabaseBackup.ps1`);
}
export function UpdateLaunchJsonForCurrentBranch(Repository) {
    StartAction(Repository,`Update-LaunchJsonForCurrentBranch.ps1`);
}
export function InstallALExtensionFromDocker(Repository) {
    StartAction(Repository,`Install-ALExtensionFromDocker.ps1`);
}
export function DiscoverAllDockerContainers(Repository) {
    StartAction(Repository,`Discover-AllDockerContainers.ps1`);
}    
export function StopAllDockerContainers(Repository) {
    StartAction(Repository,`Stop-AllDockerContainers.ps1`);
}
export function StartAllDockerContainers(Repository) {
    StartAction(Repository,`Start-AllDockerContainers.ps1`);
}
export function RemoveNAVObjectsProperties(Repository) {
    StartAction(Repository,`Remove-NAVObjectsProperties.ps1`);
}
export function DeleteOldLogs(Repository) {
    StartAction(Repository,`Delete-OldLogs.ps1`);
}
export function ImportFromAllGITtoNAV(Repository) {
    StartAction(Repository,`ImportFrom-AllGITtoNAV.ps1`);
}
export function SaveContainerCredentials(Repository) {
    StartAction(Repository,`Save-NAVContainerCredentials.ps1`);
}
export function CreateNewBranchId(Repository) {
    StartAction(Repository,`Create-NewBranchId.ps1`);
}
export function CreateNewAppId(Repository) {
    StartAction(Repository,`Create-NewAppId.ps1`);
}
export function ExportGITSourceToSource(Repository) {
    StartAction(Repository,`Export-GITSourceToSource.ps1`);
}
export function ExportSourceToGITSource(Repository) {
    StartAction(Repository,`Export-SourceToGITSource.ps1`);
}
export function NewFilesEncodingSettings(Repository) {
    StartAction(Repository,`New-FilesEncodingSettings.ps1`);
}
export function NewGITBranch(Repository) {
    vscode.window.showInputBox({
        placeHolder: "<branchname>",
        prompt: "Please provide a branch name (Press 'Enter' to confirm or 'Escape' to cancel)" }
    ).then((value: string) => {
        if (value != `` && value != null) {
            const buildSettings = `@{newBranch=\"${value}\"}`
            StartActionWithBuildSettings(Repository,`New-GITBranch.ps1`,buildSettings);
            vscode.workspace.openTextDocument(path.join(Repository,`setup.json`)).then(doc => {
                vscode.window.showTextDocument(doc);
            });
            vscode.window.showInformationMessage('Branch created, setup.json updated and opened');
        }
    })
}
export function ImportNAVContainerHelper() {
    terminal.PSTerminal.sendText(`Install-Module NAVContainerHelper -force`);
    terminal.PSTerminal.sendText(`Import-Module NAVContainerHelper -DisableNameChecking`);
}
export function ImportAppsTools(Repository) {
    StartAction(Repository,`Load-AppsTools.ps1`);
}
export function ImportIdeTools(Repository) {
    StartAction(Repository,`Load-IdeTools.ps1`);
}
export function ImportInstanceAdminTools(Repository) {
    StartAction(Repository,`Load-InstanceAdminTools.ps1`);
}
export function ImportInstanceAppTools(Repository) {
    StartAction(Repository,`Load-InstanceAppTools.ps1`);
}
export function ImportModelTools(Repository) {
    StartAction(Repository,`Load-ModelTools.ps1`);
}

function StartAction(Repository, Action) {
    console.log(`Starting: ${Action}`);
    Repository = FindGITFolder(Repository);
    terminal.PSTerminal.sendText(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"${Action}\" -Wait $false`);
}

function StartActionWithBuildSettings(Repository, Action, BuildSettings) {
    console.log(`Starting: ${Action}`);
    Repository = FindGITFolder(Repository);
    terminal.PSTerminal.sendText(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"${Action}\" -BuildSettings ${BuildSettings} -Wait $false`);
}

function FindGITFolder(Repository): String {
    const folderName = path.parse(Repository);
    while (!SetupJsonExists(path.join(folderName.dir,folderName.name))) {
        if (folderName.name == "") {
            vscode.window.showErrorMessage('Setup.json file not found for current folder');
            return;
        }
       const basefolderName = path.parse(folderName.dir);
       folderName.base = basefolderName.base;
       folderName.dir = basefolderName.dir;
       folderName.name = basefolderName.name;
    }  
    return path.join(folderName.dir,folderName.name)
}

function SetupJsonExists(FolderName): boolean {
    const setupJsonPath = path.join(FolderName,'setup.json');
    return fs.existsSync(setupJsonPath);
}


