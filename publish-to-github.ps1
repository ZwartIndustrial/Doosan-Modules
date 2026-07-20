[CmdletBinding()]
param(
    [string]$Owner = 'ZwartIndustrial',
    [string]$Repository = 'Doosan-Modules',
    [ValidateSet('public', 'private')]
    [string]$Visibility = 'public',
    [switch]$SkipRelease,
    [switch]$NoBrowser,
    [switch]$Yes,
    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Description = 'Doosan DART modules from Zwart Industrial Innovations'
$ReleaseTag = 'plcdata-v0.0.1'
$ReleaseTitle = 'PlcData 0.0.1'
$CommitMessage = 'Add PlcData 0.0.1 Doosan module'
$RepositoryRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$FullRepositoryName = "$Owner/$Repository"
$ExpectedRemote = "https://github.com/$FullRepositoryName.git"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Normalize-RemoteUrl {
    param([string]$Url)
    if ([string]::IsNullOrWhiteSpace($Url)) {
        return ''
    }
    return $Url.Trim().TrimEnd('/').Replace('.git', '').ToLowerInvariant()
}

function Invoke-NativeCommand {
    param(
        [string]$Command,
        [string[]]$Arguments,
        [string]$Action
    )
    $PreviousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & $Command @Arguments
        $CommandExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $PreviousPreference
    }
    if ($CommandExitCode -ne 0) {
        throw "$Action failed with exit code $CommandExitCode."
    }
}

function Invoke-QuietCheck {
    param(
        [string]$Command,
        [string[]]$Arguments
    )
    $PreviousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & $Command @Arguments *> $null
        return $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $PreviousPreference
    }
}

function Invoke-CaptureCheck {
    param(
        [string]$Command,
        [string[]]$Arguments
    )
    $PreviousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $CommandOutput = & $Command @Arguments 2>$null
        return [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output = ($CommandOutput -join '').Trim()
        }
    }
    finally {
        $ErrorActionPreference = $PreviousPreference
    }
}

function Invoke-CaptureRequired {
    param(
        [string]$Command,
        [string[]]$Arguments,
        [string]$Action
    )
    $Result = Invoke-CaptureCheck -Command $Command -Arguments $Arguments
    if ($Result.ExitCode -ne 0) {
        throw "$Action failed with exit code $($Result.ExitCode)."
    }
    return $Result.Output
}

try {
    Set-Location -LiteralPath $RepositoryRoot

    # The repository may have been prepared by the Codex sandbox account and
    # then published by the interactive Windows account. Trust only this exact
    # directory for Git commands during the lifetime of this script process.
    $SafeRepositoryPath = $RepositoryRoot.Replace('\', '/')
    $env:GIT_CONFIG_COUNT = '1'
    $env:GIT_CONFIG_KEY_0 = 'safe.directory'
    $env:GIT_CONFIG_VALUE_0 = $SafeRepositoryPath

    Write-Host 'Doosan Modules - GitHub Publisher' -ForegroundColor Green
    Write-Host "Folder     : $RepositoryRoot"
    Write-Host "Repository : https://github.com/$FullRepositoryName"
    Write-Host "Visibility : $Visibility"
    Write-Host "Release    : $(if ($SkipRelease) { 'skip' } else { $ReleaseTag })"

    $RequiredLocalFiles = @(
        'README.md',
        'PlcData\README.md',
        'PlcData\release\com.zii.plcdata_0.0.1.dm',
        'PlcData\release\SHA256SUMS.txt',
        'PlcData\PlcData_User_Manual_v0.0.1.pdf',
        'PlcData\RELEASE_NOTES_0.0.1.md'
    )
    foreach ($RelativeFile in $RequiredLocalFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot $RelativeFile))) {
            throw "Required file is missing: $RelativeFile"
        }
    }

    Write-Step 'Checking Git and GitHub CLI'
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'Git was not found. Install Git and run this file again.'
    }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        throw 'GitHub CLI (gh) was not found. Install GitHub CLI and run this file again.'
    }

    if ($ValidateOnly) {
        Write-Host "`nValidation passed. No Git or GitHub changes were made." -ForegroundColor Green
        exit 0
    }

    if (-not $Yes) {
        $Answer = Read-Host "`nPublish this folder to GitHub? Type Y to continue"
        if ([string]::IsNullOrWhiteSpace($Answer) -or $Answer -notmatch '^(?i:y|yes)$') {
            Write-Host 'Cancelled. Nothing was changed.' -ForegroundColor Yellow
            exit 0
        }
    }

    $AuthExitCode = Invoke-QuietCheck -Command 'gh' -Arguments @('auth', 'status', '-h', 'github.com')
    if ($AuthExitCode -ne 0) {
        Write-Host 'GitHub needs a one-time login. A browser window will open.' -ForegroundColor Yellow
        Invoke-NativeCommand -Command 'gh' -Arguments @('auth', 'login', '-h', 'github.com', '-p', 'https', '-w') -Action 'GitHub login'
    }

    $Login = Invoke-CaptureRequired -Command 'gh' -Arguments @('api', 'user', '--jq', '.login') -Action 'Reading the GitHub account'
    if ([string]::IsNullOrWhiteSpace($Login)) {
        throw 'GitHub CLI did not return a logged-in account.'
    }
    Write-Host "Logged in as: $Login" -ForegroundColor Green

    Write-Step 'Preparing the local Git repository'
    if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot '.git'))) {
        Invoke-NativeCommand -Command 'git' -Arguments @('init', '-b', 'main') -Action 'Initialising the local Git repository'
    }

    $BranchResult = Invoke-CaptureCheck -Command 'git' -Arguments @('branch', '--show-current')
    if ($BranchResult.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($BranchResult.Output)) {
        $Branch = $BranchResult.Output
    }
    else {
        # An empty repository can have an unborn branch that git branch cannot report yet.
        # HEAD still contains the intended branch name.
        $HeadResult = Invoke-CaptureCheck -Command 'git' -Arguments @('symbolic-ref', '--quiet', '--short', 'HEAD')
        if ($HeadResult.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($HeadResult.Output)) {
            $Branch = $HeadResult.Output
        }
        else {
            $Branch = 'main'
            Invoke-NativeCommand -Command 'git' -Arguments @('checkout', '-b', $Branch) -Action 'Creating the main Git branch'
        }
    }

    $GitUserName = Invoke-CaptureCheck -Command 'git' -Arguments @('config', '--get', 'user.name')
    if ($GitUserName.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($GitUserName.Output)) {
        Invoke-NativeCommand -Command 'git' -Arguments @('config', 'user.name', $Login) -Action 'Setting the local Git user name'
    }

    $GitUserEmail = Invoke-CaptureCheck -Command 'git' -Arguments @('config', '--get', 'user.email')
    if ($GitUserEmail.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($GitUserEmail.Output)) {
        Invoke-NativeCommand -Command 'git' -Arguments @('config', 'user.email', "$Login@users.noreply.github.com") -Action 'Setting the local Git email address'
    }

    Invoke-NativeCommand -Command 'git' -Arguments @('add', '-A') -Action 'Adding the repository files'

    $DiffExitCode = Invoke-QuietCheck -Command 'git' -Arguments @('diff', '--cached', '--quiet')
    if ($DiffExitCode -eq 1) {
        Invoke-NativeCommand -Command 'git' -Arguments @('commit', '-m', $CommitMessage) -Action 'Creating the Git commit'
    }
    elseif ($DiffExitCode -ne 0) {
        throw "Checking the staged files failed with exit code $DiffExitCode."
    }
    else {
        Write-Host 'There are no new local changes to commit.'
    }

    $HeadExitCode = Invoke-QuietCheck -Command 'git' -Arguments @('rev-parse', '--verify', 'HEAD')
    if ($HeadExitCode -ne 0) {
        throw 'The local repository has no commit to publish.'
    }

    Write-Step 'Creating or connecting the GitHub repository'
    $RepositoryCheckExitCode = Invoke-QuietCheck -Command 'gh' -Arguments @('repo', 'view', $FullRepositoryName, '--json', 'nameWithOwner')
    if ($RepositoryCheckExitCode -ne 0) {
        $VisibilityArgument = "--$Visibility"
        Invoke-NativeCommand -Command 'gh' -Arguments @('repo', 'create', $FullRepositoryName, $VisibilityArgument, '--description', $Description, '--source', $RepositoryRoot, '--remote', 'origin') -Action 'Creating the GitHub repository'
        Write-Host "Created https://github.com/$FullRepositoryName" -ForegroundColor Green
    }
    else {
        Write-Host "The GitHub repository already exists: $FullRepositoryName"
        $Origin = Invoke-CaptureCheck -Command 'git' -Arguments @('remote', 'get-url', 'origin')
        if ($Origin.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($Origin.Output)) {
            Invoke-NativeCommand -Command 'git' -Arguments @('remote', 'add', 'origin', $ExpectedRemote) -Action 'Adding the GitHub remote'
        }
        elseif ((Normalize-RemoteUrl $Origin.Output) -ne (Normalize-RemoteUrl $ExpectedRemote)) {
            throw "The existing origin points to '$($Origin.Output)', not '$ExpectedRemote'. It was not changed automatically."
        }
    }

    Write-Step "Pushing branch '$Branch'"
    $RemoteBranchCheck = Invoke-QuietCheck -Command 'git' -Arguments @('ls-remote', '--exit-code', '--heads', 'origin', $Branch)
    if ($RemoteBranchCheck -eq 0) {
        Invoke-NativeCommand -Command 'git' -Arguments @('fetch', 'origin', $Branch) -Action 'Fetching the existing GitHub branch'
        $AncestorCheck = Invoke-QuietCheck -Command 'git' -Arguments @('merge-base', '--is-ancestor', "origin/$Branch", 'HEAD')
        if ($AncestorCheck -ne 0) {
            throw "The GitHub branch '$Branch' contains commits that are not in this folder. No force-push was attempted."
        }
    }

    Invoke-NativeCommand -Command 'git' -Arguments @('push', '-u', 'origin', $Branch) -Action 'Pushing the files to GitHub'

    if (-not $SkipRelease) {
        Write-Step "Publishing release '$ReleaseTag'"
        $ReleaseCheckExitCode = Invoke-QuietCheck -Command 'gh' -Arguments @('release', 'view', $ReleaseTag, '--repo', $FullRepositoryName)
        if ($ReleaseCheckExitCode -eq 0) {
            Write-Host "Release '$ReleaseTag' already exists; it was left unchanged." -ForegroundColor Yellow
        }
        else {
            $ReleaseNotes = Join-Path $RepositoryRoot 'PlcData\RELEASE_NOTES_0.0.1.md'
            $ModuleFile = Join-Path $RepositoryRoot 'PlcData\release\com.zii.plcdata_0.0.1.dm'
            $ChecksumFile = Join-Path $RepositoryRoot 'PlcData\release\SHA256SUMS.txt'
            $ManualFile = Join-Path $RepositoryRoot 'PlcData\PlcData_User_Manual_v0.0.1.pdf'
            Invoke-NativeCommand -Command 'gh' -Arguments @('release', 'create', $ReleaseTag, $ModuleFile, $ChecksumFile, $ManualFile, '--repo', $FullRepositoryName, '--target', $Branch, '--title', $ReleaseTitle, '--notes-file', $ReleaseNotes) -Action 'Creating the PlcData GitHub release'
        }
    }

    $RepositoryUrl = Invoke-CaptureRequired -Command 'gh' -Arguments @('repo', 'view', $FullRepositoryName, '--json', 'url', '--jq', '.url') -Action 'Reading the repository URL'
    Write-Host "`nSuccessfully published:" -ForegroundColor Green
    Write-Host $RepositoryUrl -ForegroundColor Cyan

    if (-not $NoBrowser) {
        Invoke-NativeCommand -Command 'gh' -Arguments @('repo', 'view', $FullRepositoryName, '--web') -Action 'Opening the GitHub repository'
    }
}
catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Nothing was force-pushed or deleted.' -ForegroundColor Yellow
    exit 1
}
