extends Control

@onready var main_menu: Control = $main_menu_control
@onready var mode_select: Control = $mode_select_control

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_start_button_pressed() -> void:
	main_menu.visible = !main_menu.visible
	mode_select.visible = !mode_select.visible

func _on_quit_button_pressed() -> void:
	get_tree().quit(0)

func _on_editor_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/editor_song_list.tscn")

func _on_normal_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/song_list.tscn")

func _on_back_pressed() -> void:
	main_menu.visible = !main_menu.visible
	mode_select.visible = !mode_select.visible
