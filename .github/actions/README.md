# GitHub Actions for Godot

This repo provides a collection of Github actions related to the Godot game engine, including:
- [`install-godot`](#install-godot)
- [`build-godot`](#build-godot)

See below for more details on usage of each action.

**Note: all actions in this repo are currently designed to run inside of GitHub Actions' macOS containers, assume builds use GDScript, a released binary engine version, and do not require compilation and linking of source plugins.**

## `install-godot`

This action installs Godot to the applications directory (`~/Applications`) for a specific Godot version within the macOS runner. If the installation is to be used for building, the `install-templates` flag should be set to `true` in order to install with Godot's export templates.

### Inputs

#### `godot-version`

**Required** The version of Godot to build with. Default `0.0` (invalid).

#### `install-templates`

Whether or not to install the Godot export templates. Default `false`.

### Outputs

#### `godot-executable`

The path to the installed Godot executable.

### Example usage

```yaml
- uses: CapsCollective/godot-actions/install-godot@v1.0
  with:
    godot-version: 4.1
    install-templates: true
```

## `build-godot`

This action builds macOS, Windows, and Linux executables for the Godot project within the current directory, uploading all exports as GitHub Actions workflow artifacts where they can be later accessed either manually or via another workflow.

### Inputs

#### `build-dir`

**Required** The chosen build directory. Default `'build'`.

#### `godot-executable`

The path to the Godot executable. Default `/Applications/Godot.app/Contents/MacOS/Godot`.

### Example usage

```yaml
- uses: CapsCollective/godot-actions/build-godot@v1.1
  with:
    build-dir: 'build'
```