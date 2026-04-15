extends Node3D

@onready var audio_player: AudioStreamPlayer3D = $audio_player
@onready var e_drum_kit: Node3D = $"e-drum-kit"
@onready var game_overlay: Control = $"MeshInstance3D/SubViewport/overlay"
@onready var input_handler: Node = $"input_handler"

var music_resume_position = 0

var song = GlobalSettings.selected_song
var timestamps = []
var queued_inputs = []

var hit_windows = {
	"perfect": 0.040,   # ±40ms
	"great": 0.080,     # ±80ms
	"good": 0.120,      # ±120ms
	"ok": 0.180         # ±180ms
}

var score: int = 0
var combo: int = 0

var last_search_index = 0

var points = {"PERFECT": 100, "GREAT": 80, "GOOD": 50, "OK": 10, "MISS": 0}

func _ready() -> void:
	var song_file = FileAccess.get_file_as_string(song)
	if not song_file:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return

	var song_data = JSON.parse_string(song_file)
	timestamps = song_data["timestamps"]
	timestamps.sort_custom(func(a, b): return a["time"] < b["time"])

	for i in range(timestamps.size()):
		timestamps[i]["matched"] = false
		timestamps[i]["id"] = i

	var stream = load(song_data["audio_file"])
	if stream:
		audio_player.stream = stream


func _process(_delta: float) -> void:
	if not audio_player.playing:
		return

		var current_time = audio_player.get_playback_position()

		for input in queued_inputs:
			process_input(input, current_time)

func process_input(input: Dictionary, current_time: float) -> void:
	pass

func update_score(hit_quality: String) -> void:
	score += points.get(hit_quality)

	if hit_quality == "PERFECT" || hit_quality == "GREAT":
		combo += 1
	else:
		combo = 0

	game_overlay.set_score(score)
	game_overlay.set_combo(combo)

func find_nearby_notes(search_time: float, search_window: float) -> Array:
	var candidates = []

	var search_start = max(0, last_search_index - 20)

	for i in range(search_start, timestamps.size()):
		var note = timestamps[i]

		if note["matched"]:
			continue

		var delta = abs(note["time"] - search_time)

		if delta <= search_window:
			candidates.append(note)

		if note["time"] > search_time + search_window:
			last_search_index = i
			break

	return candidates

func evaluate_hit(delta: float) -> String:
	var abs_delta = abs(delta)

	if abs_delta <= hit_windows["perfect"]:
		return "PERFECT"
	elif abs_delta <= hit_windows["great"]:
		return "GREAT"
	elif abs_delta <= hit_windows["good"]:
		return "GOOD"
	elif abs_delta <= hit_windows["ok"]:
		return "OK"
	else:
		return "MISS"

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "intro":
		return

	input_handler.setup_input_device()
