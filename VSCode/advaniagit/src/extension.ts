'use strict';
// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';
import * as terminal from './terminal';
import * as actions from './actions';
import { workspace, WorkspaceEdit, ShellExecution } from 'vscode';

// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

    // Use the console to output diagnostic information (console.log) and errors (console.error)
    // This line of code will only be executed once when your extension is activated
    terminal.ImportAdvaniaGITModule();    
    vscode.window.showInformationMessage('Switch the terminal window to AdvaniaGIT to see details');
    console.log('Congratulations, your extension AdvaniaGIT is now active!');
    
    // The command has been defined in the package.json file
    // Now provide the implementation of the command with  registerCommand
    // The commandId parameter must match the command field in package.json
    let commandList = [
        vscode.commands.registerCommand('advaniagit.BuildDeltasInGIT', () => {actions.BuildDeltasInGIT(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.BuildNavEnvironment', () => {actions.BuildNavEnvironment(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.BuildNavEnvironmentFromGIT', () => {actions.BuildNavEnvironmentFromGIT(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.BuildNAVNewSyntaxDeltasInGIT', () => {actions.BuildNAVNewSyntaxDeltasInGIT(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.BuildSource', () => {actions.BuildSource(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.BuildTarget', () => {actions.BuildTarget(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.CheckNAVEnvironment', () => {actions.CheckNAVEnvironment(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ClearNAVCommentSection', () => {actions.ClearNAVCommentSection(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ConvertNAVNewSyntaxDeltasToAL', () => {actions.ConvertNAVNewSyntaxDeltasToAL(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.CreateCodeDeltas', () => {actions.CreateCodeDeltas(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.CreateDeltas', () => {actions.CreateDeltas(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.CreateExtension', () => {actions.CreateExtension(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.CreateNavBackup', () => {actions.CreateNavBackup(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.CreateNavBacpac', () => {actions.CreateNavBacpac(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.CreateReverseDeltas', () => {actions.CreateReverseDeltas(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.DummyAction', () => {actions.DummyAction(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ExportGITtoModified', () => {actions.ExportGITtoModified(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ExportGITtoNAVNewSyntaxModified', () => {actions.ExportGITtoNAVNewSyntaxModified(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ExportGITtoNAVNewSyntaxSource', () => {actions.ExportGITtoNAVNewSyntaxSource(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ExportGITtoSource', () => {actions.ExportGITtoSource(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ExportNavFob', () => {actions.ExportNavFob(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ExportPermissionSets', () => {actions.ExportPermissionSets(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportNavFob', () => {actions.ImportNavFob(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportRemoteNavFob', () => {actions.ImportRemoteNavFob(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportFromGITtoNAV', () => {actions.ImportFromGITtoNAV(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportFromModifiedNAVtoGIT', () => {actions.ImportFromModifiedNAVtoGIT(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportFromNAVNewSyntaxToGIT', () => {actions.ImportFromNAVNewSyntaxToGIT(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportFromNAVtoGIT', () => {actions.ImportFromNAVtoGIT(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportFromNAVtoTarget', () => {actions.ImportFromNAVtoTarget(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportFromTargetToGIT', () => {actions.ImportFromTargetToGIT(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.LoadALMenu', () => {actions.LoadALMenu(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.LoadClientMenu', () => {actions.LoadClientMenu(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.LoadCodeMenu', () => {actions.LoadCodeMenu(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.LoadExtensionMenu', () => {actions.LoadExtensionMenu(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.LoadTestMenu', () => {actions.LoadTestMenu(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ManageDatabases', () => {actions.ManageDatabases(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ManageInstances', () => {actions.ManageInstances(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.MergeDeltas', () => {actions.MergeDeltas(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.PrepareNAVEnvironment', () => {actions.PrepareNAVEnvironment(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.PrepareNAVUnitTest', () => {actions.PrepareNAVUnitTest(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.PublishExtension', () => {actions.PublishExtension(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.PublishExtensionToBaseBranch', () => {actions.PublishExtensionToBaseBranch(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.RemoveNavEnvironment', () => {actions.RemoveNavEnvironment(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ReplaceGITwithTarget', () => {actions.ReplaceGITwithTarget(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.SaveTestResults', () => {actions.SaveTestResults(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.SaveTestResultsCsv', () => {actions.SaveTestResultsCsv(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartBaseBranchClient', () => {actions.StartBaseBranchClient(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartBaseBranchWebClient', () => {actions.StartBaseBranchWebClient(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartClient', () => {actions.StartClient(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartCompile', () => {actions.StartCompile(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartDebugger', () => {actions.StartDebugger(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartFinSql', () => {actions.StartFinSql(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartTestClient', () => {actions.StartTestClient(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartVSCode', () => {actions.StartVSCode(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartVSCodeOnBaseBranch', () => {actions.StartVSCodeOnBaseBranch(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartVSCodeOnCurrentBranch', () => {actions.StartVSCodeOnCurrentBranch(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.UpdateLaunchJsonForBaseBranch', () => {actions.UpdateLaunchJsonForBaseBranch(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.UpdateLaunchJsonForCurrentBranch', () => {actions.UpdateLaunchJsonForCurrentBranch(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StartWebClient', () => {actions.StartWebClient(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.StopNAVServices', () => {actions.StopNAVServices(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.SyncRemoteNAVInstance', () => {actions.SyncRemoteNAVInstance(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.UnpublishExtension', () => {actions.UnpublishExtension(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.UnpublishExtensionFromBaseBranch', () => {actions.UnpublishExtensionFromBaseBranch(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.UpdateNAVSource', () => {actions.UpdateNAVSource(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.UpgradeNAVInstallation', () => {actions.UpgradeNAVInstallation(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.RemoveNAVObjectsProperties', () => {actions.RemoveNAVObjectsProperties(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.UploadNAVDatabaseBackup', () => {actions.UploadNAVDatabaseBackup(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.DeleteOldLogs', () => {actions.DeleteOldLogs(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.ImportFromAllGITtoNAV', () => {actions.ImportFromAllGITtoNAV(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.CreateNewBranchId', () => {actions.CreateNewBranchId(vscode.workspace.rootPath)}),
        vscode.commands.registerCommand('advaniagit.NewGITBranch', () => {actions.NewGITBranch(vscode.workspace.rootPath)})
    ];
    
    context.subscriptions.concat(commandList);
}

// this method is called when your extension is deactivated
export function deactivate() {
}