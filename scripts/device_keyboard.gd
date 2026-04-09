extends Node

signal input(drum: String)

func _input(event: InputEvent) -> void:
	if event == InputEventKey:
		_process_keyboard_input(event)


func _process_keyboard_input(key_event: InputEventKey) -> void:
	pass