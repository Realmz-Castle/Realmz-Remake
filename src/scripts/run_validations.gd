#!/usr/bin/env -S godot -s
extends SceneTree

const ValidationManager = preload("res://scripts/validation/validation.gd")

func _init():
	var manager = ValidationManager.new()
	var result = manager.run_all_validations()
	quit(0 if result else 1)