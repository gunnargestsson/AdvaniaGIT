'use strict';
import * as vscode from "vscode";
import * as terminal from './terminal';

export function BuildDeltasInGIT(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Build-DeltasInGIT.ps1\"`);
}
export function BuildNavEnvironment(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Build-NavEnvironment.ps1\"`);
}
export function BuildNavEnvironmentFromGIT(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Build-NavEnvironmentFromGIT.ps1\"`);
}
export function BuildNAVNewSyntaxDeltasInGIT(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Build-NAVNewSyntaxDeltasInGIT.ps1\"`);
}
export function BuildSource(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Build-Source.ps1\"`);
}
export function BuildTarget(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Build-Target.ps1\"`);
}
export function CheckNAVEnvironment(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Check-NAVEnvironment.ps1\"`);
}
export function ClearNAVCommentSection(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Clear-NAVCommentSection.ps1\"`);
}
export function ConvertNAVNewSyntaxDeltasToAL(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Convert-NAVNewSyntaxDeltasToAL.ps1\"`);
}
export function CreateCodeDeltas(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Create-CodeDeltas.ps1\"`);
}
export function CreateDeltas(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Create-Deltas.ps1\"`);
}
export function CreateExtension(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Create-Extension.ps1\"`);
}
export function CreateNavBackup(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Create-NavBackup.ps1\"`);
}
export function CreateNavBacpac(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Create-NavBacpac.ps1\"`);
}
export function CreateReverseDeltas(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Create-ReverseDeltas.ps1\"`);
}
export function DummyAction(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Dummy-Action.ps1\"`);
}
export function ExportGITtoModified(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"export-GITtoModified.ps1\"`);
}
export function ExportGITtoNAVNewSyntaxModified(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"export-GITtoNAVNewSyntaxModified.ps1\"`);
}
export function ExportGITtoNAVNewSyntaxSource(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"export-GITtoNAVNewSyntaxSource.ps1\"`);
}
export function ExportGITtoSource(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"export-GITtoSource.ps1\"`);
}
export function ExportNavFob(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"export-NavFob.ps1\"`);
}
export function ExportPermissionSets(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"export-PermissionSets.ps1\"`);
}
export function ImportNavFob(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Import-NavFob.ps1\"`);
}
export function ImportRemoteNavFob(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Import-RemoteNavFob.ps1\"`);
}
export function ImportFromGITtoNAV(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"ImportFrom-GITtoNAV.ps1\"`);
}
export function ImportFromModifiedNAVtoGIT(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"ImportFrom-ModifiedNAVtoGIT.ps1\"`);
}
export function ImportFromNAVNewSyntaxToGIT(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"ImportFrom-NAVNewSyntaxToGIT.ps1\"`);
}
export function ImportFromNAVtoGIT(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"ImportFrom-NAVtoGIT.ps1\"`);
}
export function ImportFromNAVtoTarget(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"ImportFrom-NAVtoTarget.ps1\"`);
}
export function ImportFromTargetToGIT(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"ImportFrom-TargetToGIT.ps1\"`);
}
export function LoadALMenu(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Load-ALMenu.ps1\"`);
}
export function LoadClientMenu(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Load-ClientMenu.ps1\"`);
}
export function LoadCodeMenu(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Load-CodeMenu.ps1\"`);
}
export function LoadExtensionMenu(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Load-ExtensionMenu.ps1\"`);
}
export function LoadTestMenu(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Load-TestMenu.ps1\"`);
}
export function ManageDatabases(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Manage-Databases.ps1\"`);
}
export function ManageInstances(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Manage-Instances.ps1\"`);
}
export function MergeDeltas(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Merge-Deltas.ps1\"`);
}
export function PrepareNAVEnvironment(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Prepare-NAVEnvironment.ps1\"`);
}
export function PrepareNAVUnitTest(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Prepare-NAVUnitTest.ps1\"`);
}
export function PublishExtension(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Publish-Extension.ps1\"`);
}
export function PublishExtensionToBaseBranch(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Publish-ExtensionToBaseBranch.ps1\"`);
}
export function RemoveNavEnvironment(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Remove-NavEnvironment.ps1\"`);
}
export function ReplaceGITwithTarget(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Replace-GITwithTarget.ps1\"`);
}
export function SaveTestResults(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Save-TestResults.ps1\"`);
}
export function SaveTestResultsCsv(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Save-TestResultsCsv.ps1\"`);
}
export function StartBaseBranchClient(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-BaseBranchClient.ps1\"`);
}
export function StartBaseBranchWebClient(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-BaseBranchWebClient.ps1\"`);
}
export function StartClient(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-Client.ps1\"`);
}
export function StartCompile(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-Compile.ps1\"`);
}
export function StartDebugger(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-Debugger.ps1\"`);
}
export function StartFinSql(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-FinSql.ps1\"`);
}
export function StartTestClient(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-TestClient.ps1\"`);
}
export function StartVSCode(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-VSCode.ps1\"`);
}
export function StartVSCodeOnBaseBranch(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-VSCodeOnBaseBranch.ps1\"`);
}
export function StartVSCodeOnCurrentBranch(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-VSCodeOnCurrentBranch.ps1\"`);
}
export function StartWebClient(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Start-WebClient.ps1\"`);
}
export function StopNAVServices(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Stop-NAVServices.ps1\"`);
}
export function SyncRemoteNAVInstance(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Sync-RemoteNAVInstance.ps1\"`);
}
export function UnpublishExtension(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Unpublish-Extension.ps1\"`);
}
export function UnpublishExtensionFromBaseBranch(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Unpublish-ExtensionFromBaseBranch.ps1\"`);
}
export function UpdateNAVSource(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Update-NAVSource.ps1\"`);
}
export function UpgradeNAVInstallation(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Upgrade-NAVInstallation.ps1\"`);
}
export function UploadNAVDatabaseBackup(Repository) {
    StartAction(`Start-AdvaniaGITAction -Repository ${Repository} -ScriptName \"Upload-NAVDatabaseBackup.ps1\"`);
}


function StartAction(Action) {
    console.log(`Starting: ${Action}`);
    terminal.PSTerminal.sendText(`${Action} -Wait $false`);
}
