extends Node

signal input(drum: String)

func _input(event: InputEvent) -> void:
	# 1. Filter: Only proceed if this is a keyboard event
	if not event is InputEventKey:
		return

	# 2. Filter: Only proceed if the key was just pressed (not released)
	if not event.pressed:
		return

	if event.is_action_pressed("Rack Tom 1", false, true): input.emit("Rack Tom 1")
	if event.is_action_pressed("Rack Tom 2", false, true): input.emit("Rack Tom 2")
	if event.is_action_pressed("Floor Tom 1", false, true): input.emit("Floor Tom 1")
	if event.is_action_pressed("Floor Tom 2", false, true): input.emit("Floor Tom 2")
	if event.is_action_pressed("Snare Drum", false, true): input.emit("Snare Drum")
	if event.is_action_pressed("Ride", false, true): input.emit("Ride")
	if event.is_action_pressed("Crash Cymbal 1", false, true): input.emit("Crash Cymbal 1")
	if event.is_action_pressed("Crash Cymbal 2", false, true): input.emit("Crash Cymbal 2")
	if event.is_action_pressed("Hi-Hat_1", false, true): input.emit("Hi-Hat_1")
	if event.is_action_pressed("Hi-Hat_2", false, true): input.emit("Hi-Hat_2")
	if event.is_action_pressed("Bass Drum", false, true): input.emit("Bass Drum")