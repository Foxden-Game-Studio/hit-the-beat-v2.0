extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton
@onready var fullscreen_toggle: CheckButton = $CheckButton

func _ready() -> void:
	var locale = TranslationServer.get_locale()
	
	fullscreen_toggle.button_pressed = GlobalSettings.window_is_fullscreen

	if locale == "en_GB":
		option_button.select(0)
	elif locale == "de":
		option_button.select(1)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		TranslationServer.set_locale("en_GB")
	elif index == 1:
		TranslationServer.set_locale("de")

func _on_check_button_pressed() -> void:
	GlobalSettings.toggle_fullscreen()
