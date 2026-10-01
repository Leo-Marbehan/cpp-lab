#Requires -Version 7
# cpp-lab shell commands. Dot-source this file, e.g. from a PowerShell profile:
#
#   . <path to cpp-lab>\scripts\cpp-lab.ps1
#
# Loading only defines functions and aliases; nothing runs until a command is called.
# Commands and examples: docs/shell.md

$CppLabRoot = Split-Path -Parent $PSScriptRoot

$cppLabPresetCompleter = {
    param($commandName, $parameterName, $wordToComplete)
    $presets = Get-Content (Join-Path $CppLabRoot 'CMakePresets.json') -Raw | ConvertFrom-Json
    $kind = if ($parameterName -eq 'Workflow') { 'workflowPresets' } else { 'configurePresets' }
    $presets.$kind | Where-Object { -not $_.hidden -and $_.name -like "$wordToComplete*" } | ForEach-Object { $_.name }
}

function Set-CppLabLocation {
    <#
    .SYNOPSIS
    Go to the cpp-lab repository.
    #>
    Set-Location $CppLabRoot
}

function Enter-CppLabDevShell {
    <#
    .SYNOPSIS
    Load the x64 Visual Studio developer environment (cl.exe, Windows SDK) into the current shell.
    #>
    if ($env:VSCMD_VER -and (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
        return
    }
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path $vswhere)) {
        throw 'vswhere.exe not found: is Visual Studio (or its Build Tools) installed?'
    }
    $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if (-not $vsPath) {
        throw 'No Visual Studio installation with the C++ x64 tools found.'
    }
    & (Join-Path $vsPath 'Common7\Tools\Launch-VsDevShell.ps1') -Arch amd64 -HostArch amd64 -SkipAutomaticLocation | Out-Null
}

function Invoke-CppLabCMake {
    # Runs a native command from the repository root, entering the developer environment first for MSVC presets.
    param([string]$Preset, [scriptblock]$Command)
    if ($Preset -like 'msvc*' -or $Preset -eq 'check-msvc') {
        Enter-CppLabDevShell
    }
    Push-Location $CppLabRoot
    try {
        & $Command
        if ($LASTEXITCODE -ne 0) {
            throw "Failed with exit code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
}

function Invoke-CppLabBuild {
    <#
    .SYNOPSIS
    Configure (first time only) and build a preset, optionally a single target.
    #>
    param(
        [ArgumentCompleter({ & $cppLabPresetCompleter @args })]
        [string]$Preset = 'msvc-debug',
        [string]$Target
    )
    Invoke-CppLabCMake $Preset {
        if (-not (Test-Path (Join-Path $CppLabRoot "build\$Preset\CMakeCache.txt"))) {
            cmake --preset $Preset
            if ($LASTEXITCODE -ne 0) { return }
        }
        if ($Target) {
            cmake --build --preset $Preset --target $Target
        } else {
            cmake --build --preset $Preset
        }
    }
}

function Invoke-CppLabTest {
    <#
    .SYNOPSIS
    Build a preset, then run its tests (optionally only those matching a regex).
    #>
    param(
        [ArgumentCompleter({ & $cppLabPresetCompleter @args })]
        [string]$Preset = 'msvc-debug',
        [string]$Filter
    )
    Invoke-CppLabBuild -Preset $Preset
    Invoke-CppLabCMake $Preset {
        if ($Filter) {
            ctest --preset $Preset -R $Filter
        } else {
            ctest --preset $Preset
        }
    }
}

function Invoke-CppLabCheck {
    <#
    .SYNOPSIS
    Run the check workflows: both by default (the gate before committing), or one of them.
    #>
    param(
        [ArgumentCompleter({ & $cppLabPresetCompleter @args })]
        [string[]]$Workflow = @('check', 'check-msvc')
    )
    foreach ($name in $Workflow) {
        Invoke-CppLabCMake $name { cmake --workflow --preset $name }
    }
}

function New-CppLabProject {
    <#
    .SYNOPSIS
    Create projects/<Name>/ from templates/project/.
    #>
    param([Parameter(Mandatory)][string]$Name)
    Invoke-CppLabCMake '' { cmake "-DNAME=$Name" -P (Join-Path $CppLabRoot 'cmake\new_project.cmake') }
}

function Remove-CppLabBuild {
    <#
    .SYNOPSIS
    Delete the build folder of one preset, or of all presets with -All.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Preset')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Preset', Position = 0)]
        [ArgumentCompleter({ & $cppLabPresetCompleter @args })]
        [string]$Preset,
        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch]$All
    )
    $target = if ($All) { Join-Path $CppLabRoot 'build' } else { Join-Path $CppLabRoot "build\$Preset" }
    if ((Test-Path $target) -and $PSCmdlet.ShouldProcess($target, 'Remove')) {
        Remove-Item -Recurse -Force $target
    }
}

Set-Alias -Name cppdir -Value Set-CppLabLocation
Set-Alias -Name vsdev -Value Enter-CppLabDevShell
Set-Alias -Name cppbuild -Value Invoke-CppLabBuild
Set-Alias -Name cpptest -Value Invoke-CppLabTest
Set-Alias -Name cppchk -Value Invoke-CppLabCheck
Set-Alias -Name cppnew -Value New-CppLabProject
Set-Alias -Name cppclean -Value Remove-CppLabBuild
