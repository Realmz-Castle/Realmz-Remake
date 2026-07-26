[CmdletBinding()]
param(
    [string]$GodotPath = "",
    [string]$ProjectPath = "",
    [string]$CampaignsDirectory = "",
    [string]$OutputPath = "",
    [string[]]$CampaignDirectoryName = @(),
    [int]$ExpectedCount = 13,
    [int]$PhaseTimeoutSeconds = 180,
    [switch]$KeepProfiles
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    $ProjectPath = [IO.Path]::GetFullPath(
        (Join-Path $PSScriptRoot "..\..\..")
    )
}
if ([string]::IsNullOrWhiteSpace($CampaignsDirectory)) {
    $CampaignsDirectory = Join-Path $ProjectPath "Campaigns"
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path (
        [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\reports"))
    ) "classic_builtin_campaign_lifecycle_acceptance.json"
}
if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    $godotCommand = Get-Command `
        "Godot_v4.7.1-stable_win64_console.exe" `
        -ErrorAction SilentlyContinue
    if ($null -eq $godotCommand) {
        $godotCommand = Get-Command "godot" -ErrorAction SilentlyContinue
    }
    if ($null -eq $godotCommand) {
        throw "Godot 4.7.1 or a godot command is required."
    }
    $GodotPath = $godotCommand.Source
}

$ProjectPath = [IO.Path]::GetFullPath($ProjectPath)
$CampaignsDirectory = [IO.Path]::GetFullPath($CampaignsDirectory)
$OutputPath = [IO.Path]::GetFullPath($OutputPath)
$GodotPath = [IO.Path]::GetFullPath($GodotPath)
if ($GodotPath.EndsWith("_console.exe", [StringComparison]::OrdinalIgnoreCase)) {
    $directGodotPath = $GodotPath.Substring(
        0,
        $GodotPath.Length - "_console.exe".Length
    ) + ".exe"
    if (Test-Path -LiteralPath $directGodotPath) {
        $GodotPath = $directGodotPath
    }
}

foreach ($requiredPath in @($GodotPath, $ProjectPath, $CampaignsDirectory)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required path does not exist: $requiredPath"
    }
}

$campaigns = @(
    Get-ChildItem -LiteralPath $CampaignsDirectory -Directory |
        ForEach-Object {
            $manifestPath = Join-Path $_.FullName "campaign.json"
            if (-not (Test-Path -LiteralPath $manifestPath)) {
                return
            }
            $manifest = Get-Content -Raw -LiteralPath $manifestPath |
                ConvertFrom-Json
            if ($manifest.campaignKind -ne "classic-compiled") {
                return
            }
            if (
                $CampaignDirectoryName.Count -gt 0 -and
                $_.Name -notin $CampaignDirectoryName
            ) {
                return
            }
            [pscustomobject]@{
                Directory = $_.Name
                FullName = $_.FullName
                Manifest = $manifest
            }
        } |
        Sort-Object Directory
)

$requiredCount = if ($CampaignDirectoryName.Count -gt 0) {
    $CampaignDirectoryName.Count
} else {
    $ExpectedCount
}
if ($campaigns.Count -ne $requiredCount) {
    throw (
        "Expected $requiredCount Classic campaigns, found $($campaigns.Count)."
    )
}

$scene = "res://scripts/classic_runtime/playtest/" +
    "classic_campaign_lifecycle_acceptance.tscn"
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())

function Invoke-AcceptancePhase {
    param(
        [Parameter(Mandatory)]
        [string]$CampaignPath,
        [Parameter(Mandatory)]
        [ValidateSet("save", "continue")]
        [string]$Phase,
        [Parameter(Mandatory)]
        [string]$ProfileRoot,
        [Parameter(Mandatory)]
        [string]$EvidencePath
    )

    $phaseFlag = if ($Phase -eq "save") {
        "--save-phase"
    } else {
        "--continue-phase"
    }
    $arguments = @(
        "--headless",
        "--single-threaded-scene",
        "--audio-driver",
        "Dummy",
        "--resolution",
        "1100x619",
        "--path",
        $ProjectPath,
        $scene,
        "--",
        $CampaignPath,
        $phaseFlag,
        "--profile-root=$ProfileRoot",
        "--evidence-path=$EvidencePath"
    )

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $GodotPath
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in $arguments) {
        [void]$startInfo.ArgumentList.Add($argument)
    }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $completed = $process.WaitForExit($PhaseTimeoutSeconds * 1000)
    if (-not $completed) {
        $process.Kill($true)
        $process.WaitForExit()
    }
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    $combined = @($stdout, $stderr) -join [Environment]::NewLine
    $markers = @(
        $combined -split "\r?\n" |
            Where-Object {
                $_ -match "CLASSIC_CAMPAIGN_LIFECYCLE (PASS|FAIL)"
            }
    )
    foreach ($marker in $markers) {
        Write-Host $marker
    }
    if (-not $completed) {
        Write-Host (
            "CLASSIC_CAMPAIGN_LIFECYCLE FAIL: phase timed out after " +
            "$PhaseTimeoutSeconds seconds"
        )
    } elseif ($process.ExitCode -ne 0) {
        Write-Host (
            "CLASSIC_CAMPAIGN_LIFECYCLE process exit: " +
            $process.ExitCode
        )
        if ($markers.Count -eq 0) {
            Write-Host $combined
        } else {
            $runtimeErrors = @(
                $combined -split "\r?\n" |
                    Where-Object {
                        $_ -match "SCRIPT ERROR|ERROR:"
                    } |
                    Select-Object -Last 20
            )
            foreach ($runtimeError in $runtimeErrors) {
                Write-Host $runtimeError
            }
        }
    }

    $phaseEvidence = if (Test-Path -LiteralPath $EvidencePath) {
        Get-Content -Raw -LiteralPath $EvidencePath | ConvertFrom-Json
    } else {
        [pscustomobject]@{
            phase = $Phase
            status = "failed"
            errors = @("The acceptance process did not write evidence.")
        }
    }
    [pscustomobject]@{
        ExitCode = if ($phaseEvidence.status -eq "passed") {
            0
        } elseif ($completed) {
            $process.ExitCode
        } else {
            1
        }
        Evidence = $phaseEvidence
    }
}

$campaignResults = @()
$allPassed = $true
foreach ($campaign in $campaigns) {
    Write-Host "Checking $($campaign.Directory)"
    $profileRoot = Join-Path $tempBase (
        "realmz-classic-lifecycle-" + [Guid]::NewGuid().ToString("N")
    )
    [void](New-Item -ItemType Directory -Path $profileRoot)
    try {
        $saveEvidencePath = Join-Path $profileRoot "save-evidence.json"
        $continueEvidencePath = Join-Path $profileRoot "continue-evidence.json"
        $saveResult = Invoke-AcceptancePhase `
            -CampaignPath $campaign.FullName `
            -Phase "save" `
            -ProfileRoot $profileRoot `
            -EvidencePath $saveEvidencePath
        if ($saveResult.ExitCode -eq 0) {
            $continueResult = Invoke-AcceptancePhase `
                -CampaignPath $campaign.FullName `
                -Phase "continue" `
                -ProfileRoot $profileRoot `
                -EvidencePath $continueEvidencePath
        } else {
            $continueResult = [pscustomobject]@{
                ExitCode = 1
                Evidence = [pscustomobject]@{
                    phase = "continue"
                    status = "skipped"
                    errors = @("Save phase failed.")
                }
            }
        }
        $passed = (
            $saveResult.ExitCode -eq 0 -and
            $continueResult.ExitCode -eq 0
        )
        if (-not $passed) {
            $allPassed = $false
        }
        $campaignResults += [ordered]@{
            directory = $campaign.Directory
            id = [string]$campaign.Manifest.id
            name = [string]$campaign.Manifest.name
            start = [ordered]@{
                levelType = [string]$campaign.Manifest.start.levelType
                levelIndex = [int]$campaign.Manifest.start.levelIndex
                x = [int]$campaign.Manifest.start.x
                y = [int]$campaign.Manifest.start.y
            }
            save = $saveResult.Evidence
            continue = $continueResult.Evidence
            status = if ($passed) { "passed" } else { "failed" }
        }
    } finally {
        if (-not $KeepProfiles) {
            $resolvedProfileRoot = [IO.Path]::GetFullPath($profileRoot)
            $profileLeaf = Split-Path -Leaf $resolvedProfileRoot
            if (
                $resolvedProfileRoot.StartsWith(
                    $tempBase,
                    [StringComparison]::OrdinalIgnoreCase
                ) -and
                $profileLeaf -like "realmz-classic-lifecycle-*"
            ) {
                Remove-Item -LiteralPath $resolvedProfileRoot -Recurse -Force
            } else {
                throw "Refusing to remove unexpected profile path."
            }
        }
    }
}

$passedCount = @(
    $campaignResults | Where-Object { $_.status -eq "passed" }
).Count
$report = [ordered]@{
    schemaVersion = 1
    kind = "classic-built-in-campaign-lifecycle-acceptance"
    processBoundary = (
        "Closed phase evidence is authoritative; a Windows teardown fault " +
        "after evidence is reported to the console and does not replace it."
    )
    status = if ($allPassed) { "passed" } else { "failed" }
    expectedCampaigns = $requiredCount
    totals = [ordered]@{
        campaigns = $campaignResults.Count
        passed = $passedCount
        failed = $campaignResults.Count - $passedCount
    }
    campaigns = $campaignResults
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    [void](New-Item -ItemType Directory -Path $outputDirectory)
}
$json = $report | ConvertTo-Json -Depth 20
[IO.File]::WriteAllText(
    $OutputPath,
    $json + [Environment]::NewLine,
    [Text.UTF8Encoding]::new($false)
)
Write-Host "Wrote $OutputPath"

if (-not $allPassed) {
    exit 1
}
