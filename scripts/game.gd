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
var look_ahead_time = 1500

var points = {"PERFECT": 100, "GREAT": 80, "GOOD": 50, "OK": 10, "MISS": 0}
var feedback_color = {"PERFECT": Color.LIGHT_BLUE, "GREAT": Color.GREEN, "GOOD": Color.GREEN_YELLOW, "OK": Color.YELLOW, "MISS": Color.RED}

var drum_map = {
	"Rack Tom 1": "tom 1",
	"Rack Tom 2": "tom 2",
	"Floor Tom 1": "tom 1",
	"Floor Tom 2": "tom 2",
	"Snare Drum": "snare",
	"Ride": "ride",
	"Crash Cymbal 1": "crash",
	"Crash Cymbal 2": "crash",
	"Hi-Hat_1": "hi-hat",
	"Hi-Hat_2": "hi-hat",
	"Bass Drum": "bass",
}

var drum_map_reverse = {
	"tom 1": "Rack Tom 1",
	"tom 2": "Rack Tom 2",
	"snare": "Snare Drum",
	"ride": "Ride",
	"crash": "Crash Cymbal 1",
	"hi-hat": "Hi-Hat_1",
	"bass": "Bass Drum",
}

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
	var processed = []

	for input in queued_inputs:
		process_input(input, current_time)
		processed.append(input)

	for input in processed:
		queued_inputs.erase(input)
	if queued_inputs.size() != 0:
		print(queued_inputs.size())

func process_input(input: Dictionary, current_time: float) -> void:
	var input_type = normalize_drum_name(input["type"])
	var candidates = find_nearby_notes(current_time, hit_windows["ok"])

	var best_match = find_best_match(candidates, input_type, current_time)

	if best_match:
		var delta = current_time - best_match["time"]
		var hit_quality = evaluate_hit(delta)
		best_match["matched"] = true
		update_score(hit_quality)
		e_drum_kit.on_drum_hit(drum_map_reverse[best_match["type"]], feedback_color[hit_quality])
	else:
		combo = 0


func normalize_drum_name(drum_name: String) -> String:
	return drum_map.get(drum_name, drum_name.to_lower())

func find_best_match(candidates: Array, input_type: String, search_time: float) -> Dictionary:
	var best_match = {}
	var closest_distance = INF

	for candidate in candidates:
		if normalize_drum_name(candidate["type"]) != input_type:
			continue

		var distance = abs(candidate["time"] - search_time)
		if distance < closest_distance:
			closest_distance = distance
			best_match = candidate

	return best_match

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
