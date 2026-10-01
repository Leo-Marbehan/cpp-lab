#Requires -Version 7
# cpp-lab shell commands. Dot-source this file, e.g. from a PowerShell profile:
#
#   . <path to cpp-lab>\scripts\cpp-lab.ps1
#
# Loading only defines functions and aliases; nothing runs until a command is called.
# Commands and examples: docs/shell.md

$CppLabRoot = Split-Path -Parent $PSScriptRoot

# Pinned toolchain, used by Install-CppLabToolchain (winget) and Install-CppLabPortableToolchain (CI downloads).
# Changing a version: update the URL and SHA-256 too, and docs/setup.md (ADR 0012).
$CppLabPinnedTools = [ordered]@{
    CMake = @{
        Version = '4.4.3'
        Url = 'https://github.com/Kitware/CMake/releases/download/v4.4.3/cmake-4.4.3-windows-x86_64.zip'
        Sha256 = '4d52ebab7193a698651639ed80d8d04fd903358843572cf44c7fd234cb7c26ab'
        Bin = 'cmake-4.4.3-windows-x86_64\bin'
    }
    Ninja = @{
        Version = '1.13.2'
        Url = 'https://github.com/ninja-build/ninja/releases/download/v1.13.2/ninja-win.zip'
        Sha256 = '07fc8261b42b20e71d1720b39068c2e14ffcee6396b76fb7a795fb460b78dc65'
        Bin = '.'
    }
    LLVM = @{
        Version = '21.1.0'
        Url = 'https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.0/LLVM-21.1.0-win64.exe'
        Sha256 = 'e751be8019b7500b100456c915b4b3c339d8d88b81b3aad49796d39f700e7ef3'
        Bin = 'bin'
    }
}

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

function Enable-CppLabGitHooks {
    <#
    .SYNOPSIS
    Use the repository's git hooks (.githooks/: pre-commit, commit-msg) in this clone. Needed once per clone.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess($CppLabRoot, 'git config core.hooksPath .githooks')) {
        git -C $CppLabRoot config core.hooksPath .githooks
        Write-Host 'Git hooks enabled (.githooks/). Private word list: .git/info/forbidden-words (one per line).'
    }
}

function Install-CppLabToolchain {
    <#
    .SYNOPSIS
    Install the toolchain this repository is tested with (docs/setup.md). Use -WhatIf to see what would happen.
    .DESCRIPTION
    Missing tools are installed with winget at the pinned version. Tools already installed are never upgraded or
    downgraded: a different version is only reported. Visual Studio Build Tools are installed (with .vsconfig) only when
    no Visual Studio exists; an existing installation missing components gets the command to add them.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $tools = @(
        @{ Name = 'Git'; Id = 'Git.Git'; Version = $null; Command = 'git'; Dir = "$env:ProgramFiles\Git\cmd" }
        @{ Name = 'CMake'; Id = 'Kitware.CMake'; Version = $CppLabPinnedTools.CMake.Version; Command = 'cmake'
            Dir = "$env:ProgramFiles\CMake\bin"; Probe = { param($exe) (& $exe --version)[0] -replace '^cmake version ', '' } }
        @{ Name = 'Ninja'; Id = 'Ninja-build.Ninja'; Version = $CppLabPinnedTools.Ninja.Version; Command = 'ninja'
            Dir = $null; Probe = { param($exe) & $exe --version } }
        @{ Name = 'LLVM'; Id = 'LLVM.LLVM'; Version = $CppLabPinnedTools.LLVM.Version; Command = 'clang'
            Dir = "$env:ProgramFiles\LLVM\bin"; Probe = { param($exe) ((& $exe --version)[0] -split ' ')[2] } }
        @{ Name = 'VSCode'; Id = 'Microsoft.VisualStudioCode'; Version = $null; Command = 'code'
            Dir = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin" }
    )

    function Update-SessionPath {
        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')
    }

    foreach ($tool in $tools) {
        $label = if ($tool.Version) { "$($tool.Name) $($tool.Version)" } else { $tool.Name }

        $exe = (Get-Command $tool.Command -ErrorAction SilentlyContinue | Select-Object -First 1).Source
        if (-not $exe -and $tool.Dir) {
            $exe = Get-ChildItem $tool.Dir -Filter "$($tool.Command).*" -ErrorAction SilentlyContinue |
                Where-Object Extension -in '.exe', '.cmd' | Select-Object -First 1 -ExpandProperty FullName
            if ($exe -and $PSCmdlet.ShouldProcess('user PATH', "Add $($tool.Dir)")) {
                $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
                [Environment]::SetEnvironmentVariable('Path', "$userPath;$($tool.Dir)", 'User')
                Update-SessionPath
            }
        }

        if ($exe) {
            if ($tool.Version -and $tool.Probe) {
                $found = & $tool.Probe $exe
                if ($found -ne $tool.Version) {
                    Write-Warning ("$($tool.Name) $found is installed; this repository is tested with $($tool.Version). " +
                        "To match: winget install --id $($tool.Id) --exact --version $($tool.Version) --force")
                    continue
                }
            }
            Write-Host "ok        $label"
            continue
        }

        $arguments = @('install', '--id', $tool.Id, '--exact', '--silent', '--accept-package-agreements',
            '--accept-source-agreements')
        if ($tool.Version) {
            $arguments += @('--version', $tool.Version)
        }
        if ($PSCmdlet.ShouldProcess($label, 'winget install')) {
            winget @arguments
            Update-SessionPath
            if (-not (Get-Command $tool.Command -ErrorAction SilentlyContinue) -and $tool.Dir -and (Test-Path $tool.Dir)) {
                $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
                [Environment]::SetEnvironmentVariable('Path', "$userPath;$($tool.Dir)", 'User')
                Update-SessionPath
            }
            Write-Host "installed $label"
        }
    }

    $vsconfig = Join-Path $CppLabRoot '.vsconfig'
    $components = (Get-Content $vsconfig -Raw | ConvertFrom-Json).components
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    $anyVs = if (Test-Path $vswhere) { & $vswhere -products * -property installationPath | Select-Object -First 1 }
    $completeVs = if ($anyVs) { & $vswhere -products * -requires @components -property installationPath | Select-Object -First 1 }
    if ($completeVs) {
        Write-Host "ok        Visual Studio C++ tools ($completeVs)"
    } elseif ($anyVs) {
        $setup = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\setup.exe'
        Write-Warning ("Visual Studio at '$anyVs' lacks components from .vsconfig. Add them with the Visual Studio " +
            "Installer (More > Import configuration > .vsconfig), or from an administrator shell:`n" +
            "  & '$setup' modify --installPath '$anyVs' --config '$vsconfig' --passive")
    } elseif ($PSCmdlet.ShouldProcess('Visual Studio Build Tools (components from .vsconfig)', 'winget install')) {
        winget install --id Microsoft.VisualStudio.BuildTools --exact --accept-package-agreements --accept-source-agreements `
            --override "--wait --passive --config `"$vsconfig`""
        Write-Host 'installed Visual Studio Build Tools'
    }

    if (Get-Command code -ErrorAction SilentlyContinue) {
        $recommended = (Get-Content (Join-Path $CppLabRoot '.vscode\extensions.json') -Raw | ConvertFrom-Json).recommendations
        $installed = code --list-extensions
        foreach ($extension in $recommended) {
            if ($installed -contains $extension) {
                Write-Host "ok        VSCode extension $extension"
            } elseif ($PSCmdlet.ShouldProcess("VSCode extension $extension", 'code --install-extension')) {
                code --install-extension $extension
            }
        }
    }

    Write-Host 'Open a new terminal so that PATH changes apply everywhere, then: docs/setup.md, "Verify".'
}

function Install-CppLabPortableToolchain {
    <#
    .SYNOPSIS
    Download the pinned CMake, Ninja and LLVM into a folder and put them first on PATH. Used by CI.
    .DESCRIPTION
    No installation and no administrator rights: archives are extracted (LLVM's installer with 7-Zip). Every download
    is checked against its pinned SHA-256. In GitHub Actions, the folders are also added to GITHUB_PATH for later steps.
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [ValidateSet('CMake', 'Ninja', 'LLVM')][string[]]$Tool = @('CMake', 'Ninja', 'LLVM')
    )
    New-Item -ItemType Directory -Force $Path | Out-Null
    $previousProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    try {
        foreach ($name in $Tool) {
            $pinned = $CppLabPinnedTools[$name]
            $archive = Join-Path $Path (Split-Path -Leaf $pinned.Url)
            $destination = Join-Path $Path $name.ToLower()
            Invoke-WebRequest -Uri $pinned.Url -OutFile $archive -UseBasicParsing
            $hash = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLower()
            if ($hash -ne $pinned.Sha256) {
                throw "$name download has SHA-256 $hash, expected $($pinned.Sha256)."
            }
            if ($archive -like '*.zip') {
                Expand-Archive -Path $archive -DestinationPath $destination -Force
            } else {
                $sevenZip = (Get-Command 7z -ErrorAction SilentlyContinue).Source ?? "$env:ProgramFiles\7-Zip\7z.exe"
                if (-not (Test-Path $sevenZip)) {
                    throw '7-Zip is needed to extract the LLVM installer.'
                }
                & $sevenZip x $archive "-o$destination" -y | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    throw "7-Zip failed to extract $archive."
                }
            }
            Remove-Item $archive
            $bin = (Resolve-Path (Join-Path $destination $pinned.Bin)).Path
            $env:Path = "$bin;$env:Path"
            if ($env:GITHUB_PATH) {
                Add-Content -Path $env:GITHUB_PATH -Value $bin
            }
            Write-Host "$name $($pinned.Version) -> $bin"
        }
    } finally {
        $ProgressPreference = $previousProgress
    }
}

function Set-CppLabGitHubSettings {
    <#
    .SYNOPSIS
    Apply the repository settings described in docs/github.md with the GitHub CLI (gh). Use -WhatIf to preview.
    .DESCRIPTION
    Safe to run again: settings are set to the same values, the ruleset from .github/rulesets/main.json is created
    or updated by name. Needs `gh auth login` with admin rights on the repository.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # owner/name; default: the repository of the current clone's remote.
        [string]$Repository
    )
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        throw 'GitHub CLI (gh) not found: winget install --id GitHub.cli --exact'
    }
    if (-not $Repository) {
        Push-Location $CppLabRoot
        try {
            $Repository = gh repo view --json nameWithOwner --jq .nameWithOwner
        } finally {
            Pop-Location
        }
        if (-not $Repository) {
            throw 'No GitHub repository found for this clone; pass -Repository owner/name.'
        }
    }

    $steps = @(
        @{ What = 'features: issues on; wiki, projects, discussions off'
            Args = @('repo', 'edit', $Repository, '--enable-issues', '--enable-wiki=false', '--enable-projects=false',
                '--enable-discussions=false') }
        @{ What = 'pull requests: squash and rebase merges only, delete branches after merge, no auto-merge'
            Args = @('repo', 'edit', $Repository, '--enable-squash-merge', '--enable-rebase-merge',
                '--enable-merge-commit=false', '--delete-branch-on-merge', '--enable-auto-merge=false') }
        @{ What = 'description and topics'
            Args = @('repo', 'edit', $Repository, '--description',
                'Personal C++20 practice monorepo: CMake presets, MSVC + clang, clang-tidy, doctest',
                '--add-topic', 'cpp', '--add-topic', 'cpp20', '--add-topic', 'cmake', '--add-topic', 'clang-tidy') }
        @{ What = 'secret scanning and push protection'
            Args = @('repo', 'edit', $Repository, '--enable-secret-scanning', '--enable-secret-scanning-push-protection') }
        @{ What = 'private vulnerability reporting'
            Args = @('api', '--method', 'PUT', "repos/$Repository/private-vulnerability-reporting") }
        @{ What = 'Dependabot alerts'
            Args = @('api', '--method', 'PUT', "repos/$Repository/vulnerability-alerts") }
        @{ What = 'Dependabot security updates'
            Args = @('api', '--method', 'PUT', "repos/$Repository/automated-security-fixes") }
        @{ What = 'Actions: read-only GITHUB_TOKEN, cannot approve pull requests'
            Args = @('api', '--method', 'PUT', "repos/$Repository/actions/permissions/workflow",
                '-f', 'default_workflow_permissions=read', '-F', 'can_approve_pull_request_reviews=false') }
        @{ What = 'Actions: approval required for workflows from all outside contributors'
            Args = @('api', '--method', 'PUT', "repos/$Repository/actions/permissions/fork-pr-contributor-approval",
                '-f', 'approval_policy=all_external_contributors') }
    )

    foreach ($step in $steps) {
        if ($PSCmdlet.ShouldProcess($Repository, $step.What)) {
            gh @($step.Args) | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed: $($step.What). Set it by hand (docs/github.md)."
            } else {
                Write-Host "set       $($step.What)"
            }
        }
    }

    $rulesetFile = Join-Path $CppLabRoot '.github\rulesets\main.json'
    $rulesetName = (Get-Content $rulesetFile -Raw | ConvertFrom-Json).name
    if ($PSCmdlet.ShouldProcess($Repository, "ruleset '$rulesetName' from .github/rulesets/main.json")) {
        $existing = gh api "repos/$Repository/rulesets" --jq ".[] | select(.name == `"$rulesetName`") | .id"
        if ($existing) {
            gh api --method PUT "repos/$Repository/rulesets/$existing" --input $rulesetFile | Out-Null
        } else {
            gh api --method POST "repos/$Repository/rulesets" --input $rulesetFile | Out-Null
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed: ruleset '$rulesetName'. Import it by hand (docs/github.md)."
        } else {
            Write-Host "set       ruleset '$rulesetName'"
        }
    }
}

Set-Alias -Name cppdir -Value Set-CppLabLocation
Set-Alias -Name vsdev -Value Enter-CppLabDevShell
Set-Alias -Name cppbuild -Value Invoke-CppLabBuild
Set-Alias -Name cpptest -Value Invoke-CppLabTest
Set-Alias -Name cppchk -Value Invoke-CppLabCheck
Set-Alias -Name cppnew -Value New-CppLabProject
Set-Alias -Name cppclean -Value Remove-CppLabBuild
