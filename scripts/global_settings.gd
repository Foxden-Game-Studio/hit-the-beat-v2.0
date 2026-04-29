extends Node

var window_size_windowed: Vector2
var window_is_fullscreen: bool = false
var input_device = 0
var selected_song = ""
var edit_song = false

var device_index_to_string = {
	0: "midi_drum_kit",
	1: "keyboard",
	2: "touch_screen",
	3: "diy_drum_kit"
}

func _ready():
	var viewport_width = ProjectSettings.get("display/window/size/viewport_width")
	var viewport_height = ProjectSettings.get("display/window/size/viewport_height")

	window_size_windowed = Vector2(viewport_width, viewport_height)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_toggle_fullscreen"):
		toggle_fullscreen()

func toggle_fullscreen():
	if window_is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(window_size_windowed)
		window_is_fullscreen = !window_is_fullscreen
	elif !window_is_fullscreen:
		window_size_windowed = DisplayServer.window_get_size()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		window_is_fullscreen = !window_is_fullscreen
