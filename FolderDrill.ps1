<#
.SYNOPSIS
    For each top-level folder in a directory, writes a list of all its subfolders
    (recursively) into a text file named after that folder.

.DESCRIPTION
    1. Gets the list of folders directly inside -Path (default: current directory).
    2. For each of those folders, recursively finds every subfolder underneath it.
    3. Writes the full paths of those subfolders into "<FolderName>.txt", saved in -Path.

.PARAMETER Path
    The directory to scan. Defaults to the current working directory.

.NOTES
    Before running this script, you may need to update your execution policy:
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

.EXAMPLE
    .\List-Subfolders.ps1
    Runs against the current directory.

.EXAMPLE
    .\List-Subfolders.ps1 -Path "C:\Projects"
    Runs against C:\Projects instead.
#>
 
param(
    [string]$Path
)

if (-not $Path) {
    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $browser.Description = "Select the folder to process"
    $browser.ShowNewFolderButton = $false
    if ($browser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $Path = $browser.SelectedPath
    } else {
        Write-Host "No folder selected. Exiting."
        exit
    }
}
 
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$folderName = Split-Path -Leaf $Path
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputDir = Join-Path -Path $scriptDir -ChildPath "${folderName}_${timestamp}"
New-Item -Path $outputDir -ItemType Directory | Out-Null

$topLevelFolders = Get-ChildItem -Path $Path -Directory -ErrorAction Stop

foreach ($folder in $topLevelFolders) {
    $outputFile = Join-Path -Path $outputDir -ChildPath "$($folder.Name).txt"

    $subfolders = Get-ChildItem -Path $folder.FullName -Directory -Recurse -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName

    if ($subfolders) {
        $subfolders | Out-File -FilePath $outputFile -Encoding UTF8
    }
    else {
        New-Item -Path $outputFile -ItemType File -Force | Out-Null
    }

    Write-Host "Wrote $($subfolders.Count) subfolder(s) of '$($folder.Name)' to $outputFile"
}

Write-Host "Output saved to $outputDir"