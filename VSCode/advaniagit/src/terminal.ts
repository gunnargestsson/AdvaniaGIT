'use strict';
import * as vscode from "vscode";

export const PSTerminal = vscode.window.createTerminal(`AdvaniaGIT`);

export function ImportAdvaniaGITModule() {
    PSTerminal.sendText(`import-module AdvaniaGIT -DisableNameChecking`);
}

