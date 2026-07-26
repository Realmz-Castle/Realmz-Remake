[CmdletBinding()]
param(
    [string]$GodotPath = "",
    [string]$ProjectPath = "",
    [string]$CampaignDirectory = "",
    [string]$RoutePath = "",
    [string]$OutputPath = "",
    [int]$TimeoutSeconds = 180,
    [switch]$KeepProfile
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    $ProjectPath = [IO.Path]::GetFullPath(
        (Join-Path $PSScriptRoot "..\..\..")
    )
}
if ([string]::IsNullOrWhiteSpace($CampaignDirectory)) {
    $CampaignDirectory = Join-Path $ProjectPath (
        "Campaigns\Assault on Giant Mountain (Classic)"
    )
}
if ([string]::IsNullOrWhiteSpace($RoutePath)) {
    $RoutePath = Join-Path $ProjectPath (
        "scripts\classic_runtime\playtest\routes\" +
        "assault_on_giant_mountain.json"
    )
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $ProjectPath (
        "scripts\classic_runtime\reports\" +
        "classic_assault_on_giant_mountain_route_acceptance.json"
    )
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
$CampaignDirectory = [IO.Path]::GetFullPath($CampaignDirectory)
$RoutePath = [IO.Path]::GetFullPath($RoutePath)
$OutputPath = [IO.Path]::GetFullPath($OutputPath)
$GodotPath = [IO.Path]::GetFullPath($GodotPath)

foreach (
    $requiredPath in @(
        $GodotPath,
        $ProjectPath,
        $CampaignDirectory,
        $RoutePath
    )
) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required path does not exist: $requiredPath"
    }
}

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$profileRoot = Join-Path $tempBase (
    "realmz-classic-route-" + [Guid]::NewGuid().ToString("N")
)
$profileRoot = [IO.Path]::GetFullPath($profileRoot)
if (-not $profileRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to create an acceptance profile outside the temp directory."
}
[void](New-Item -ItemType Directory -Path $profileRoot)
$phaseEvidencePath = Join-Path $profileRoot "route-evidence.json"

$scene = "res://scripts/classic_runtime/playtest/" +
    "classic_scenario_route_acceptance.tscn"
$arguments = @(
    "--headless",
    "--audio-driver",
    "Dummy",
    "--resolution",
    "1100x619",
    "--path",
    $ProjectPath,
    $scene,
    "--",
    $CampaignDirectory,
    "--route=$RoutePath",
    "--profile-root=$profileRoot",
    "--evidence-path=$phaseEvidencePath"
)

try {
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
    $completed = $process.WaitForExit($TimeoutSeconds * 1000)
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
                $_ -match "CLASSIC_SCENARIO_ROUTE (PASS|FAIL)"
            }
    )
    foreach ($marker in $markers) {
        Write-Host $marker
    }
    $processSucceeded = $completed -and $process.ExitCode -eq 0
    if (-not $completed) {
        Write-Host (
            "CLASSIC_SCENARIO_ROUTE FAIL: timed out after " +
            "$TimeoutSeconds seconds"
        )
    } elseif (-not $processSucceeded) {
        Write-Host "CLASSIC_SCENARIO_ROUTE process exit: $($process.ExitCode)"
        $runtimeErrors = @(
            $combined -split "\r?\n" |
                Where-Object {
                    $_ -match "SCRIPT ERROR|ERROR:"
                } |
                Select-Object -Last 30
        )
        foreach ($runtimeError in $runtimeErrors) {
            Write-Host $runtimeError
        }
    }

    if (-not (Test-Path -LiteralPath $phaseEvidencePath)) {
        Write-Host $combined
        throw "The acceptance process did not write route evidence."
    }
    if (-not $processSucceeded) {
        throw (
            "Classic scenario route process did not exit cleanly: " +
            "$($process.ExitCode)"
        )
    }
    $evidence = Get-Content -Raw -LiteralPath $phaseEvidencePath |
        ConvertFrom-Json
    if ($evidence.status -ne "passed") {
        Write-Host $combined
        throw (
            "Classic scenario route acceptance failed: " +
            ($evidence.failures -join "; ")
        )
    }

    $outputDirectory = Split-Path -Parent $OutputPath
    [void](New-Item -ItemType Directory -Force -Path $outputDirectory)
    [IO.File]::WriteAllText(
        $OutputPath,
        (Get-Content -Raw -LiteralPath $phaseEvidencePath),
        [Text.UTF8Encoding]::new($false)
    )
    $hash = (
        Get-FileHash -Algorithm SHA256 -LiteralPath $OutputPath
    ).Hash.ToLowerInvariant()
    Write-Host "CLASSIC_SCENARIO_ROUTE report: $OutputPath"
    Write-Host "CLASSIC_SCENARIO_ROUTE sha256: $hash"
} finally {
    if (-not $KeepProfile -and (Test-Path -LiteralPath $profileRoot)) {
        $resolvedProfile = [IO.Path]::GetFullPath($profileRoot)
        if (
            -not $resolvedProfile.StartsWith(
                $tempBase,
                [StringComparison]::OrdinalIgnoreCase
            )
        ) {
            throw "Refusing to remove an acceptance profile outside temp."
        }
        Remove-Item -LiteralPath $resolvedProfile -Recurse -Force
    } elseif ($KeepProfile) {
        Write-Host "CLASSIC_SCENARIO_ROUTE profile: $profileRoot"
    }
}
