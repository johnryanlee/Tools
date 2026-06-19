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
 
.EXAMPLE
    .\List-Subfolders.ps1
    Runs against the current directory.
 
.EXAMPLE
    .\List-Subfolders.ps1 -Path "C:\Projects"
    Runs against C:\Projects instead.
#>
 
param(
    [string]$Path = (Get-Location).Path
)
 
# Top-level folders only
$topLevelFolders = Get-ChildItem -Path $Path -Directory -ErrorAction Stop
 
foreach ($folder in $topLevelFolders) {
    $outputFile = Join-Path -Path $Path -ChildPath "$($folder.Name).txt"
 
    # All subfolders and further subfolders, recursively
    $subfolders = Get-ChildItem -Path $folder.FullName -Directory -Recurse -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName
 
    if ($subfolders) {
        $subfolders | Out-File -FilePath $outputFile -Encoding UTF8
    }
    else {
        # No subfolders found; create an empty file for consistency
        New-Item -Path $outputFile -ItemType File -Force | Out-Null
    }
 
    Write-Host "Wrote $($subfolders.Count) subfolder(s) of '$($folder.Name)' to $outputFile"
}