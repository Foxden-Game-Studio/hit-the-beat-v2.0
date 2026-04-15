extends Node

@onready var game: Node3D = $"/root/Game"

func setup_input_device():
	var device_input_handler = Node.new()
	device_input_handler.name = "device_input_handler"
	device_input_handler.set_script(load("res://scripts/device_" + GlobalSettings.device_index_to_string[GlobalSettings.input_device] + ".gd"))
	device_input_handler.connect("input", _on_input)

	add_child(device_input_handler)

func _on_input(type: String):
	var current_time = game.audio_player.get_playback_position()
	game.queued_inputs.push_back({"type": type, "time": current_time})
