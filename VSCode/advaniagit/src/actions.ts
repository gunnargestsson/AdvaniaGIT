'use strict';
import * as vscode from "vscode";
import * as terminal from './terminal';
import * as path from "path";
import * as fs from "fs";

export function BuildDeltasInGIT(Repository) {
    StartAction(Repository,`Build-DeltasInGIT.ps1`);
}
export function BuildDeltasFromSource(Repository) {
    StartAction(Repository,`Build-DeltasFromSource.ps1`);
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
export function CreateCodeDeltas(Repository) {
    StartAction(Repository,`Create-CodeDeltas.ps1`);
}
export function CreateDeltas(Repository) {
    StartAction(Repository,`Create-Deltas.ps1`);
}
export function CreateExtension(Repository) {
    StartAction(Repository,`Create-Extension.ps1`);
}
export function CreateNavBackup(Repository) {
    StartAction(Repository,`Create-NavBackup.ps1`);
}
export function CreateNavBacpac(Repository) {
    StartAction(Repository,`Create-NavBacpac.ps1`);
}
export function CreateReverseDeltas(Repository) {
    StartAction(Repository,`Create-ReverseDeltas.ps1`);
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
export function LoadALMenu(Repository) {
    StartAction(Repository,`Load-ALMenu.ps1`);
}
export function LoadClientMenu(Repository) {
    StartAction(Repository,`Load-ClientMenu.ps1`);
}
export function LoadCodeMenu(Repository) {
    StartAction(Repository,`Load-CodeMenu.ps1`);
}
export function LoadExtensionMenu(Repository) {
    StartAction(Repository,`Load-ExtensionMenu.ps1`);
}
export function LoadTestMenu(Repository) {
    StartAction(Repository,`Load-TestMenu.ps1`);
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
export function PublishExtension(Repository) {
    StartAction(Repository,`Publish-Extension.ps1`);
}
export function PublishExtensionToBaseBranch(Repository) {
    StartAction(Repository,`Publish-ExtensionToBaseBranch.ps1`);
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
export function StartBaseBranchClient(Repository) {
    StartAction(Repository,`Start-BaseBranchClient.ps1`);
}
export function StartBaseBranchWebClient(Repository) {
    StartAction(Repository,`Start-BaseBranchWebClient.ps1`);
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
export function StartTestClient(Repository) {
    StartAction(Repository,`Start-TestClient.ps1`);
}
export function StartVSCode(Repository) {
    StartAction(Repository,`Start-VSCode.ps1`);
}
export function StartVSCodeOnBaseBranch(Repository) {
    StartAction(Repository,`Start-VSCodeOnBaseBranch.ps1`);
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
export function UnpublishExtension(Repository) {
    StartAction(Repository,`Unpublish-Extension.ps1`);
}
export function UnpublishExtensionFromBaseBranch(Repository) {
    StartAction(Repository,`Unpublish-ExtensionFromBaseBranch.ps1`);
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
export function UpdateLaunchJsonForBaseBranch(Repository) {
    StartAction(Repository,`Update-LaunchJsonForBaseBranch.ps1`);
}
export function UpdateLaunchJsonForCurrentBranch(Repository) {
    StartAction(Repository,`Update-LaunchJsonForCurrentBranch.ps1`);
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

export function CreateNewBranchId(Repository) {
    StartAction(Repository,`Create-NewBranchId.ps1`);
}
export function ExportGITSourceToSource(Repository) {
    StartAction(Repository,`Export-GITSourceToSource.ps1`);
}
export function ExportSourceToGITSource(Repository) {
    StartAction(Repository,`Export-SourceToGITSource.ps1`);
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
export function InstallNAVContainerHelper() {
    terminal.PSTerminal.sendText(`Install-Module NAVContainerHelper -force`);
}
export function LoadAppsTools(Repository) {
    StartAction(Repository,`Load-AppsTools.ps1`);
}
export function LoadIdeTools(Repository) {
    StartAction(Repository,`Load-IdeTools.ps1`);
}
export function LoadInstanceAdminTools(Repository) {
    StartAction(Repository,`Load-InstanceAdminTools.ps1`);
}
export function LoadInstanceAppTools(Repository) {
    StartAction(Repository,`Load-InstanceAppTools.ps1`);
}
export function LoadModelTools(Repository) {
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


