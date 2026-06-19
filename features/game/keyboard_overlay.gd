extends Control
@export var game: Node3D

func _on_button_pressed() -> void:
	game.hide_keybidingHud()
