extends Node3D

@onready var audio_player: AudioStreamPlayer3D = $audio_player
@onready var e_drum_kit: Node3D = $"e-drum-kit"

var song = GlobalSettings.selected_song
var timestamps = []
var queued_inputs = []

func _ready() -> void:
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
	pass

func setup_input_device():
	var input_handler = Node.new()
	input_handler.name = "input_handler"
	input_handler.set_script(load("res://scripts/device_" + GlobalSettings.device_index_to_string[GlobalSettings.input_device] + ".gd"))
	input_handler.connect("input", _on_input)

	add_child(input_handler)

func _on_input(type: String):
	var current_time = audio_player.get_playback_position()
	queued_inputs.push_back({"type": type, "time": current_time})
	e_drum_kit.on_drum_hit(type)


func _on_audio_player_finished() -> void:
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "intro":
		return

	setup_input_device()


func _on_menu_button_pressed() -> void:
	$AnimationPlayer.play("toggle_game_menu")
	$MeshInstance3D/SubViewport/overlay/game_statistics.visible = false
	$MeshInstance3D/SubViewport/overlay/game_menu.visible = true


func _on_resume_button_pressed() -> void:
	$AnimationPlayer.play_backwards("toggle_game_menu")
	$MeshInstance3D/SubViewport/overlay/game_menu.visible = false
	$MeshInstance3D/SubViewport/overlay/game_statistics.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
