extends Node2D

@onready var audio_player: AudioStreamPlayer2D = $audio_player

var song = GlobalSettings.selected_song
var timestamps = []
var queued_inputs = []

func _ready() -> void:
	setup_input_device()

	var song_file = FileAccess.get_file_as_string(song)
	if not song_file:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return

	var song_data = JSON.parse_string(song_file)
	timestamps = song_data["timestamps"]

	var stream = load(song_data["audio_file"])
	if stream:
		audio_player.stream = stream


func _process(_delta: float) -> void:
	if not audio_player.playing:
		return

func setup_input_device():
	var input_handler = Node.new()
	input_handler.name = "input_handler"
	input_handler.set_script(load("res://scrips/device_" + GlobalSettings.device_index_to_string[GlobalSettings.input_device] + ".gd"))
	input_handler.connect("input", _on_input)

	add_child(input_handler)

func _on_input(type: String):
	var current_time = audio_player.get_playback_position()
	queued_inputs.push_back({"type": type, "time": current_time})


func _on_audio_player_finished() -> void:
	pass # Replace with function body.
