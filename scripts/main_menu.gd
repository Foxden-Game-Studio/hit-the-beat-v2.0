extends Control

func _ready() -> void:
	pass


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/song_list.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit(0)
