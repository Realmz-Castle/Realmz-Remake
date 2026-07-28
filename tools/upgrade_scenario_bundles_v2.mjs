import fs from "node:fs";
import path from "node:path";

const roots = process.argv.slice(2);
if (roots.length === 0) {
  throw new Error("Pass one or more bundle roots");
}

const ignoredNames = new Set(["invalid_campaign"]);
let upgraded = 0;
let actions = 0;

function jsonFilesUnder(root) {
  const result = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const entryPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      result.push(...jsonFilesUnder(entryPath));
    } else if (entry.name === "campaign.json") {
      result.push(entryPath);
    }
  }
  return result;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value, compact) {
  const text = compact
    ? `${JSON.stringify(value)}\n`
    : `${JSON.stringify(value, null, 2)}\n`;
  fs.writeFileSync(filePath, text);
}

function classicAction(action) {
  if (action.kind === "semantic") {
    return action;
  }
  const rawCode = Number(action.rawCode ?? action.code ?? 0);
  const code = rawCode < 0 && ![-14, -23].includes(rawCode)
    ? Math.abs(rawCode)
    : rawCode;
  actions += 1;
  return {
    kind: "classic",
    ...action,
    rawCode,
    code,
    id: Number(action.id ?? 0),
    gosub: rawCode < 0 && ![-14, -23].includes(rawCode),
  };
}

function upgradeActionCollections(document, collections) {
  for (const collection of collections) {
    for (const record of document[collection] ?? []) {
      record.actions = (record.actions ?? []).map(classicAction);
    }
  }
}

for (const root of roots) {
  for (const manifestPath of jsonFilesUnder(path.resolve(root))) {
    const bundleRoot = path.dirname(manifestPath);
    if (ignoredNames.has(path.basename(bundleRoot))) {
      continue;
    }
    const originalText = fs.readFileSync(manifestPath, "utf8");
    const compact = !originalText.includes("\n");
    const manifest = JSON.parse(originalText);
    if (
      manifest.format !== "realmz-remake-classic-campaign"
      && manifest.format !== "realmz-remake-scenario"
    ) {
      continue;
    }

    manifest.format = "realmz-remake-scenario";
    manifest.formatVersion = 2;
    manifest.campaignKind ??= "classic-compiled";
    manifest.files.runtime = "runtime.json";

    const scriptsPath = path.join(bundleRoot, manifest.files.scripts);
    const scripts = readJson(scriptsPath);
    upgradeActionCollections(scripts, ["triggers"]);
    writeJson(scriptsPath, scripts, true);

    const encountersPath = path.join(bundleRoot, manifest.files.encounters);
    const encounters = readJson(encountersPath);
    upgradeActionCollections(encounters, ["simpleEncounters", "complexEncounters"]);
    writeJson(encountersPath, encounters, true);

    const runtime = {
      schemaVersion: 1,
      recommendedGameplayProfile: "core.classic",
      requiredExtensions: [],
      bindings: {
        spells: {},
        items: {},
        encounters: {},
        monsterAi: {},
        lifecycle: {},
      },
      targetSupport: {
        realmzRemake: true,
        nativeRealmz: true,
        remakeOnlyReasons: [],
      },
    };
    writeJson(path.join(bundleRoot, "runtime.json"), runtime, compact);
    writeJson(manifestPath, manifest, compact);
    upgraded += 1;
  }
}

process.stdout.write(
  `Upgraded ${upgraded} scenario bundles and ${actions} action records to v2.\n`,
);
