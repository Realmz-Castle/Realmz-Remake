param(
    [Parameter(Mandatory = $true)]
    [string]$ScenarioRoot,

    [Parameter(Mandatory = $true)]
    [string]$BundleRoot,

    [Parameter(Mandatory = $true)]
    [string]$SharedDataRoot,

    [Parameter(Mandatory = $true)]
    [string]$Godot,

    [string]$OutputPath = (
        Join-Path $PSScriptRoot '..\classic_known_custom_rule_manifest.json'
    )
)

$ErrorActionPreference = 'Stop'

$spellBytes = 30
$spellRecords = 105
$raceBytes = 408
$casteBytes = 576
$ruleRecords = 30
$firstPartyScenarios = @(
    'Assault on Giant Mountain'
    'Castle in the Clouds'
    'City of Bywater'
    'Destroy the Necronomicon'
    'Grilochs Revenge'
    'Half Truth'
    'Mithril Vault'
    'Prelude to Pestilence'
    'Trouble in the Sword Lands'
    'Twin Sands of Time'
    'War in the Sword Lands'
    'White Dragon'
    'Wrath of the Mind Lords'
)

function Get-Sha256 {
    param([byte[]]$Bytes)
    return [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData($Bytes)
    ).ToLowerInvariant()
}

function Get-RecordBytes {
    param(
        [byte[]]$Bytes,
        [int]$RecordIndex,
        [int]$RecordBytes
    )
    $start = $RecordIndex * $RecordBytes
    $record = [byte[]]::new($RecordBytes)
    [Array]::Copy($Bytes, $start, $record, 0, $RecordBytes)
    return $record
}

function Test-NonzeroRecord {
    param([byte[]]$Bytes)
    foreach ($value in $Bytes) {
        if ($value -ne 0) {
            return $true
        }
    }
    return $false
}

function Get-PackedCustomSpellId {
    param([int]$RecordIndex)
    return [int](
        5101 + [int][Math]::Floor($RecordIndex / 15) * 100 + ($RecordIndex % 15)
    )
}

function Get-PackedSharedSpellId {
    param([int]$RecordIndex)
    $spellClass = [Math]::Floor($RecordIndex / 105) + 1
    $classRecord = $RecordIndex % 105
    $level = [Math]::Floor($classRecord / 15) + 1
    $slot = ($classRecord % 15) + 1
    return [int]($spellClass * 1000 + $level * 100 + $slot)
}

function Get-CanonicalCampaignId {
    param([string]$Scenario)
    $slug = ($Scenario.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
    return "scenario:$slug"
}

function Get-RuleTableSelection {
    param(
        [string]$Scenario,
        [string]$FileName,
        [int]$RecordBytes,
        [byte[]]$SharedBytes
    )
    $path = Join-Path (Join-Path $ScenarioRoot $Scenario) $FileName
    if (-not (Test-Path -LiteralPath $path)) {
        return [ordered]@{
            source = 'shared'
            status = 'shared-fallback'
            changedRecordIds = @()
            fileBytes = 0
            fileSha256 = ''
        }
    }
    $bytes = [IO.File]::ReadAllBytes($path)
    $expectedBytes = $RecordBytes * $ruleRecords
    if ($bytes.Length -ne $expectedBytes) {
        return [ordered]@{
            source = if ($firstPartyScenarios -contains $Scenario) {
                'shared'
            } else {
                'scenario-local'
            }
            status = 'malformed-legacy'
            changedRecordIds = @()
            fileBytes = $bytes.Length
            fileSha256 = Get-Sha256 $bytes
            expectedBytes = $expectedBytes
        }
    }
    $changed = @()
    for ($recordIndex = 0; $recordIndex -lt $ruleRecords; $recordIndex++) {
        $record = Get-RecordBytes $bytes $recordIndex $RecordBytes
        $shared = Get-RecordBytes $SharedBytes $recordIndex $RecordBytes
        if ((Get-Sha256 $record) -ne (Get-Sha256 $shared)) {
            $changed += $recordIndex
        }
    }
    if ($firstPartyScenarios -contains $Scenario) {
        return [ordered]@{
            source = 'shared'
            status = 'inactive-first-party-copy'
            changedRecordIds = $changed
            fileBytes = $bytes.Length
            fileSha256 = Get-Sha256 $bytes
        }
    }
    return [ordered]@{
        source = 'scenario-local'
        status = if ($changed.Count -eq 0) { 'inactive-no-op-copy' } else { 'active-changed' }
        changedRecordIds = $changed
        fileBytes = $bytes.Length
        fileSha256 = Get-Sha256 $bytes
    }
}

foreach ($path in @($ScenarioRoot, $BundleRoot, $SharedDataRoot)) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Directory not found: $path"
    }
}
if (-not (Test-Path -LiteralPath $Godot -PathType Leaf)) {
    throw "Godot executable not found: $Godot"
}

$bundleDirectories = @(
    Get-ChildItem -LiteralPath $BundleRoot -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'campaign.json') } |
        Sort-Object Name
)
if ($bundleDirectories.Count -eq 0) {
    throw "No Classic bundles found under $BundleRoot"
}

$arguments = @(
    '--headless'
    '--path'
    (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
    '--script'
    'res://scripts/classic_runtime/tests/report_classic_spell_support.gd'
    '--'
) + @($bundleDirectories.FullName) + @('--json')
$reportOutput = & $Godot @arguments 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "Classic spell usage report failed with exit code $LASTEXITCODE"
}
$reportLine = $reportOutput | Where-Object { $_ -like '{*' } | Select-Object -Last 1
if (-not $reportLine) {
    throw 'Classic spell usage report did not produce JSON'
}
$usageReport = $reportLine | ConvertFrom-Json -Depth 100

$bundleByScenario = @{}
foreach ($bundleDirectory in $bundleDirectories) {
    $manifest = Get-Content -Raw -LiteralPath (
        Join-Path $bundleDirectory.FullName 'campaign.json'
    ) | ConvertFrom-Json -Depth 20
    $rules = Get-Content -Raw -LiteralPath (
        Join-Path $bundleDirectory.FullName 'classic\rules.json'
    ) | ConvertFrom-Json -Depth 100
    $bundleByScenario[$manifest.name] = [ordered]@{
        id = $manifest.id
        rules = $rules
    }
}

$usageByDefinition = @{}
foreach ($row in $usageReport.spells) {
    foreach ($definition in $row.definitions) {
        $usageByDefinition[$definition.stableId] = [ordered]@{
            active = [bool]$definition.active
            usages = [object[]]@($definition.consumers)
        }
    }
}

$supportMatrix = Get-Content -Raw -LiteralPath (
    Join-Path $PSScriptRoot '..\classic_spell_support_matrix.json'
) | ConvertFrom-Json -Depth 100
$supportById = @{}
foreach ($row in $supportMatrix.spells) {
    $supportById[[int]$row.classicSpellId] = $row
}
$inventory = Get-Content -Raw -LiteralPath (
    Join-Path $PSScriptRoot '..\classic_core_spell_inventory.json'
) | ConvertFrom-Json -Depth 100
$inventoryById = @{}
foreach ($row in $inventory.spells) {
    $inventoryById[[int]$row.packedSpellId] = $row
}

$sharedSpellPath = Join-Path $SharedDataRoot 'Data S'
$sharedRacePath = Join-Path $SharedDataRoot 'Data Race'
$sharedCastePath = Join-Path $SharedDataRoot 'Data Caste'
$sharedSpells = [IO.File]::ReadAllBytes($sharedSpellPath)
$sharedRaces = [IO.File]::ReadAllBytes($sharedRacePath)
$sharedCastes = [IO.File]::ReadAllBytes($sharedCastePath)
if ($sharedSpells.Length -lt 525 * $spellBytes) {
    throw "Shared Data S is shorter than 525 records: $($sharedSpells.Length) bytes"
}
if ($sharedRaces.Length -lt $ruleRecords * $raceBytes) {
    throw "Shared Data Race is shorter than 30 records: $($sharedRaces.Length) bytes"
}
if ($sharedCastes.Length -lt $ruleRecords * $casteBytes) {
    throw "Shared Data Caste is shorter than 30 records: $($sharedCastes.Length) bytes"
}

$sharedSpellMatches = @{}
for ($recordIndex = 0; $recordIndex -lt 525; $recordIndex++) {
    $record = Get-RecordBytes $sharedSpells $recordIndex $spellBytes
    $hash = Get-Sha256 $record
    $packedId = Get-PackedSharedSpellId $recordIndex
    if (-not $sharedSpellMatches.ContainsKey($hash)) {
        $sharedSpellMatches[$hash] = @()
    }
    $sharedSpellMatches[$hash] += [ordered]@{
        classicSpellId = $packedId
        displayName = [string]$inventoryById[$packedId].displayName
        supportStatus = if ($supportById.ContainsKey($packedId)) {
            [string]$supportById[$packedId].supportStatus
        } else {
            'unclassified'
        }
    }
}

$spellPayloadByHash = [ordered]@{}
$racePayloadByHash = [ordered]@{}
$castePayloadByHash = [ordered]@{}
$tableReferences = @()
$malformedLegacy = @()
$scenarioEntries = @()

foreach ($scenarioDirectory in Get-ChildItem -LiteralPath $ScenarioRoot -Directory | Sort-Object Name) {
    $scenario = $scenarioDirectory.Name
    if (-not $bundleByScenario.ContainsKey($scenario)) {
        throw "No compiled audit bundle matches scenario '$scenario'"
    }
    $bundle = $bundleByScenario[$scenario]
    $campaignId = [string]$bundle.id
    if (-not $campaignId) {
        $campaignId = Get-CanonicalCampaignId $scenario
    }
    $rules = $bundle.rules
    $spellPath = Join-Path $scenarioDirectory.FullName 'Data Spell'
    $spellFile = $null
    $populatedSpells = 0
    if (Test-Path -LiteralPath $spellPath) {
        $spellFile = [IO.File]::ReadAllBytes($spellPath)
        if ($spellFile.Length -lt $spellRecords * $spellBytes) {
            $malformedLegacy += [ordered]@{
                scenario = $scenario
                campaignId = $campaignId
                sourceFile = 'Data Spell'
                bytes = $spellFile.Length
                expectedMinimumBytes = $spellRecords * $spellBytes
                sha256 = Get-Sha256 $spellFile
                status = 'malformed-legacy'
            }
        } else {
            for ($recordIndex = 0; $recordIndex -lt $spellRecords; $recordIndex++) {
                $recordBytes = Get-RecordBytes $spellFile $recordIndex $spellBytes
                if (-not (Test-NonzeroRecord $recordBytes)) {
                    continue
                }
                $populatedSpells++
                $hash = Get-Sha256 $recordBytes
                $record = $rules.spellOverrides |
                    Where-Object { [int]$_.id -eq $recordIndex } |
                    Select-Object -First 1
                $packedId = Get-PackedCustomSpellId $recordIndex
                $stableId = "$campaignId`:spell:$recordIndex"
                $activity = $usageByDefinition[$stableId]
                $active = $null -ne $activity -and [bool]$activity.active
                $special = [int]$record.special
                $supportedNativeCandidates = @(
                    $sharedSpellMatches[$hash] |
                        Where-Object { $_.supportStatus -eq 'supported' }
                )
                $classification = if ($supportedNativeCandidates.Count -gt 0) {
                    'native-equivalent'
                } elseif ($active) {
                    if ($special -eq 0) { 'generically-representable' } else { 'progression-blocker' }
                } elseif ($special -eq 0) {
                    'generically-representable'
                } else {
                    'unsupported-optional'
                }
                if (-not $spellPayloadByHash.Contains($hash)) {
                    $spellPayloadByHash[$hash] = [ordered]@{
                        payloadId = "spell-sha256:$hash"
                        sha256 = $hash
                        bytes = $spellBytes
                        rawHex = [Convert]::ToHexString($recordBytes).ToLowerInvariant()
                        special = $special
                        nativeEquivalentCandidates = [object[]]@(
                            $sharedSpellMatches[$hash] |
                                Where-Object { $null -ne $_ }
                        )
                        definitions = @()
                    }
                }
                $spellPayloadByHash[$hash].definitions += [ordered]@{
                    stableId = $stableId
                    campaignId = $campaignId
                    scenario = $scenario
                    sourceFile = 'Data Spell'
                    recordIndex = $recordIndex
                    byteOffset = $recordIndex * $spellBytes
                    packedSpellId = $packedId
                    displayName = [string]$record.displayName
                    active = $active
                    classification = $classification
                    consumers = [object[]]@(
                        $activity.usages |
                            Where-Object { $null -ne $_ }
                    )
                }
            }
        }
    }

    $raceSelection = Get-RuleTableSelection $scenario 'Data Race' $raceBytes $sharedRaces
    $casteSelection = Get-RuleTableSelection $scenario 'Data Caste' $casteBytes $sharedCastes
    foreach ($specification in @(
        [ordered]@{
            kind = 'race'
            sourceFile = 'Data Race'
            recordBytes = $raceBytes
            selection = $raceSelection
            payloads = $racePayloadByHash
        }
        [ordered]@{
            kind = 'caste'
            sourceFile = 'Data Caste'
            recordBytes = $casteBytes
            selection = $casteSelection
            payloads = $castePayloadByHash
        }
    )) {
        $selection = $specification.selection
        $tableStableId = "$campaignId`:rule-table:$($specification.kind)"
        $recordPayloadIds = @()
        if ($selection.status -eq 'malformed-legacy') {
            $malformedLegacy += [ordered]@{
                scenario = $scenario
                campaignId = $campaignId
                sourceFile = $specification.sourceFile
                bytes = $selection.fileBytes
                expectedBytes = $selection.expectedBytes
                sha256 = $selection.fileSha256
                status = 'malformed-legacy'
                consumer = 'Classic loadprofile'
            }
        } elseif ($selection.fileBytes -gt 0) {
            $fileBytes = [IO.File]::ReadAllBytes(
                (Join-Path $scenarioDirectory.FullName $specification.sourceFile)
            )
            foreach ($recordIndex in $selection.changedRecordIds) {
                $recordBytes = Get-RecordBytes (
                    $fileBytes
                ) ([int]$recordIndex) ([int]$specification.recordBytes)
                $hash = Get-Sha256 $recordBytes
                $payloadId = "$($specification.kind)-sha256:$hash"
                $recordPayloadIds += $payloadId
                if (-not $specification.payloads.Contains($hash)) {
                    $specification.payloads[$hash] = [ordered]@{
                        payloadId = $payloadId
                        sha256 = $hash
                        bytes = [int]$specification.recordBytes
                        definitions = @()
                    }
                }
                $specification.payloads[$hash].definitions += [ordered]@{
                    stableId = "$campaignId`:$($specification.kind):$recordIndex"
                    campaignId = $campaignId
                    scenario = $scenario
                    sourceFile = $specification.sourceFile
                    recordIndex = [int]$recordIndex
                    byteOffset = [int]$recordIndex * [int]$specification.recordBytes
                    active = $selection.source -eq 'scenario-local'
                    classification = if ($selection.source -eq 'scenario-local') {
                        'generically-representable'
                    } else {
                        'fidelity-only'
                    }
                    consumer = 'Classic loadprofile'
                }
            }
        }
        if ($selection.fileBytes -gt 0) {
            $tableReferences += [ordered]@{
                stableId = $tableStableId
                campaignId = $campaignId
                scenario = $scenario
                kind = $specification.kind
                sourceFile = $specification.sourceFile
                source = $selection.source
                status = $selection.status
                changedRecordIds = @($selection.changedRecordIds)
                recordPayloadIds = $recordPayloadIds
                fileBytes = $selection.fileBytes
                fileSha256 = $selection.fileSha256
                consumer = 'Classic loadprofile'
            }
        }
    }

    $scenarioEntries += [ordered]@{
        campaignId = $campaignId
        scenario = $scenario
        distribution = if ($firstPartyScenarios -contains $scenario) {
            'first-party'
        } else {
            'third-party'
        }
        spellTable = [ordered]@{
            present = $null -ne $spellFile
            bytes = if ($spellFile) { $spellFile.Length } else { 0 }
            sha256 = if ($spellFile) { Get-Sha256 $spellFile } else { '' }
            populatedRecords = $populatedSpells
        }
        raceTable = $raceSelection
        casteTable = $casteSelection
    }
}

$spellPayloads = @($spellPayloadByHash.Values)
$racePayloads = @($racePayloadByHash.Values)
$castePayloads = @($castePayloadByHash.Values)
$spellDefinitions = @($spellPayloads.definitions)
$activeSpellDefinitions = @($spellDefinitions | Where-Object active)
$classificationTotals = [ordered]@{}
foreach ($classification in @(
    'native-equivalent'
    'generically-representable'
    'fidelity-only'
    'unsupported-optional'
    'progression-blocker'
)) {
    $classificationTotals[$classification] = @(
        $spellDefinitions | Where-Object classification -eq $classification
    ).Count
}

$manifest = [ordered]@{
    schemaVersion = 1
    audit = [ordered]@{
        issue = 'ISY-425'
        compatibilityProfile = 'realmz-7.1'
        sourceMechanism = [ordered]@{
            spells = 'Classic loads a present scenario Data Spell table'
            races = 'Classic selects scenario Data Race only for menu IDs 20 and above'
            castes = 'Classic selects scenario Data Caste only for menu IDs 20 and above'
        }
        classifications = @(
            'native-equivalent'
            'generically-representable'
            'fidelity-only'
            'unsupported-optional'
            'progression-blocker'
        )
    }
    corpus = [ordered]@{
        scenarios = $scenarioEntries
        firstPartyScenarios = $firstPartyScenarios
        sharedRules = [ordered]@{
            dataS = [ordered]@{
                bytes = $sharedSpells.Length
                sha256 = Get-Sha256 $sharedSpells
            }
            dataRace = [ordered]@{
                comparedBytes = $ruleRecords * $raceBytes
                sha256 = Get-Sha256 (
                    Get-RecordBytes $sharedRaces 0 ($ruleRecords * $raceBytes)
                )
            }
            dataCaste = [ordered]@{
                comparedBytes = $ruleRecords * $casteBytes
                sha256 = Get-Sha256 (
                    Get-RecordBytes $sharedCastes 0 ($ruleRecords * $casteBytes)
                )
            }
        }
    }
    totals = [ordered]@{
        scenarios = $scenarioEntries.Count
        spellTables = @($scenarioEntries | Where-Object { $_.spellTable.present }).Count
        populatedSpellDefinitions = $spellDefinitions.Count
        uniqueSpellPayloads = $spellPayloads.Count
        activeSpellDefinitions = $activeSpellDefinitions.Count
        activeSpellConsumers = @($activeSpellDefinitions.consumers).Count
        raceTables = @($tableReferences | Where-Object kind -eq 'race').Count
        uniqueChangedRacePayloads = $racePayloads.Count
        casteTables = @($tableReferences | Where-Object kind -eq 'caste').Count
        uniqueChangedCastePayloads = $castePayloads.Count
        malformedLegacyPayloads = $malformedLegacy.Count
        classifications = $classificationTotals
    }
    spellPayloads = $spellPayloads
    racePayloads = $racePayloads
    castePayloads = $castePayloads
    tableReferences = $tableReferences
    malformedLegacyPayloads = $malformedLegacy
    representativeFixtures = @(
        [ordered]@{ id = 'empty-spell-template'; expected = 'no-definition' }
        [ordered]@{ id = 'representable-custom-spell'; expected = 'generically-representable' }
        [ordered]@{ id = 'unsupported-special-spell'; expected = 'progression-blocker' }
        [ordered]@{ id = 'no-op-race-caste-table'; expected = 'inactive-no-op-copy' }
        [ordered]@{ id = 'active-changed-override'; expected = 'generically-representable' }
    )
}

$resolvedOutput = [IO.Path]::GetFullPath($OutputPath)
$outputDirectory = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}
$json = $manifest | ConvertTo-Json -Depth 100
[IO.File]::WriteAllText(
    $resolvedOutput,
    $json + [Environment]::NewLine,
    [Text.UTF8Encoding]::new($false)
)
Write-Output $resolvedOutput
Write-Output ($manifest.totals | ConvertTo-Json -Compress -Depth 10)
