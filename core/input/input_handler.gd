extends Node

@onready var game: Node3D = $"/root/Game"

var input_device_enabled = false

func setup_input_device():
	var device_input_handler: Node = Node.new()
	device_input_handler.name = "device_input_handler"
	device_input_handler.set_script(load("res://core/input/devices/device_" + GlobalSettings.device_index_to_string[GlobalSettings.input_device] + ".gd"))
	device_input_handler.connect("input", _on_input)

	add_child(device_input_handler)
	
func enable_input_device():
	input_device_enabled = true
	
func disable_input_device():
	input_device_enabled = false

func _on_input(type: String):
	if input_device_enabled:
		var current_time = game.audio_player.get_playback_position()
		game.queued_inputs.push_back({"type": type, "time": current_time})
		print("hit: type: " + type + " time: " + String.num(current_time))
