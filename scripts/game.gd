extends Node3D

@onready var audio_player: AudioStreamPlayer3D = $audio_player
@onready var e_drum_kit: Node3D = $"e-drum-kit"
@onready var game_overlay: Control = $"MeshInstance3D/SubViewport/overlay"
@onready var input_handler: Node = $"input_handler"

var music_resume_position = 0

var song = GlobalSettings.selected_song
var timestamps = []
var queued_inputs = []

var score: int = 0
var combo: int = 0

var last_search_index = 0
var look_ahead_time = 1500

func _ready() -> void:
	var song_file = FileAccess.get_file_as_string(song)
	if not song_file:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return

	var song_data = JSON.parse_string(song_file)
	game_overlay.set_song_title(song_data["song_name"])
	timestamps = song_data["timestamps"]
	timestamps.sort_custom(func(a, b): return a["time"] < b["time"])

	for i in range(timestamps.size()):
		timestamps[i]["matched"] = false
		timestamps[i]["id"] = i

	var stream = load(song_data["audio_file"])
	if stream:
		audio_player.stream = stream


func _process(_delta: float) -> void:
	var processed = []
	if not audio_player.playing:
		for input in queued_inputs:
			e_drum_kit.on_drum_hit(input["type"], Color.BLUE_VIOLET)
			processed.append(input)

		for input in processed:
			queued_inputs.erase(input)

		processed.clear()
		return

	var current_time = audio_player.get_playback_position()

	for input in queued_inputs:
		process_input(input, current_time)
		processed.append(input)

	for input in processed:
		queued_inputs.erase(input)

	processed.clear()

func process_input(input: Dictionary, current_time: float) -> void:
	var input_type = input["type"]
	var candidates = find_nearby_notes(current_time, GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.OK])

	var best_match = find_best_match(candidates, input_type, current_time)

	if best_match:
		var delta = current_time - best_match["time"]
		var hit_quality = evaluate_hit(delta)
		best_match["matched"] = true
		update_score(hit_quality)
		e_drum_kit.on_drum_hit(best_match["type"], GlobalDefinitions.FEEDBACK_COLOR[hit_quality])
	else:
		e_drum_kit.on_drum_hit(input_type, GlobalDefinitions.FEEDBACK_COLOR[GlobalDefinitions.MISS])
		combo = 0

func find_best_match(candidates: Array, input_type: String, search_time: float) -> Dictionary:
	var best_match = {}
	var closest_distance = INF

	for candidate in candidates:
		if candidate["type"] != input_type:
			continue

		var distance = abs(candidate["time"] - search_time)
		if distance < closest_distance:
			closest_distance = distance
			best_match = candidate

	return best_match

func update_score(hit_quality: String) -> void:
	score += GlobalDefinitions.POINTS.get(hit_quality)

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

	if abs_delta <= GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.PERFECT]:
		return GlobalDefinitions.PERFECT
	elif abs_delta <= GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.GREAT]:
		return GlobalDefinitions.GREAT
	elif abs_delta <= GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.GOOD]:
		return GlobalDefinitions.GOOD
	elif abs_delta <= GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.OK]:
		return GlobalDefinitions.OK
	else:
		return GlobalDefinitions.MISS

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "intro":
		return

	input_handler.setup_input_device()
