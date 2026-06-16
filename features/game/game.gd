extends Node3D

@onready var audio_player: AudioStreamPlayer3D = $audio_player
@onready var e_drum_kit: Node3D = $"e-drum-kit"
@onready var game_overlay: Control = $"MeshInstance3D/SubViewport/overlay"
@onready var input_handler: Node = $"input_handler"

var VisualCue = preload("res://features/game/visual_cue.gd")

var music_resume_position = 0
var countdown_timer: float = 0.0
var is_game_paused: bool = true
var countdown_label: Label

func get_current_time() -> float:
	if countdown_timer > 0.0:
		if music_resume_position == 0:
			return -countdown_timer
		else:
			return music_resume_position
	return audio_player.get_playback_position()

var song = GlobalSettings.selected_song
var timestamps = []
var queued_inputs = []

var score: int = 0
var combo: int = 0
var best_combo: int = 0

var perfect: int = 0
var great: int = 0
var good: int = 0
var ok: int = 0
var miss: int = 0

var last_search_index = 0
var last_visual_index = 0
var look_ahead_time = 1500

func _ready() -> void:
	var song_file = FileAccess.get_file_as_string(song)
	if not song_file:
		get_tree().change_scene_to_file("res://features/main_menu/main_menu.tscn")
		return

	var song_data = JSON.parse_string(song_file)
	game_overlay.set_song_title(song_data["song_name"])
	timestamps = song_data["timestamps"]
	timestamps.sort_custom(func(a, b): return a["time"] < b["time"])

	for i in range(timestamps.size()):
		timestamps[i]["matched"] = false
		timestamps[i]["id"] = i

	var stream = Helpers.load_audio_file(song_data["audio_file"])
	if stream:
		audio_player.stream = stream
	
	if GlobalSettings.input_device != 1:
		$KeyboardOverlay.visible = false
		
	countdown_label = Label.new()
	countdown_label.set_anchors_preset(Control.PRESET_CENTER)
	countdown_label.add_theme_font_size_override("font_size", 120)
	countdown_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	countdown_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	countdown_label.add_theme_constant_override("outline_size", 10)
	countdown_label.text = ""
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_overlay.add_child(countdown_label)
func _process(_delta: float) -> void:	
	var processed = []
	
	if is_game_paused:
		for input in queued_inputs:
			e_drum_kit.on_drum_hit(input["type"], Color.BLUE_VIOLET)
			processed.append(input)
		for input in processed:
			queued_inputs.erase(input)
		processed.clear()
		return
	
	if countdown_timer > 0.0:
		countdown_timer -= _delta
		if countdown_label:
			countdown_label.text = str(ceil(countdown_timer))
		if countdown_timer <= 0.0:
			countdown_timer = 0.0
			if countdown_label:
				countdown_label.text = ""
			if not audio_player.playing:
				audio_player.play(music_resume_position)
			else:
				audio_player.stream_paused = false

	if not audio_player.playing and countdown_timer <= 0.0:
		for input in queued_inputs:
			e_drum_kit.on_drum_hit(input["type"], Color.BLUE_VIOLET)
			processed.append(input)
		for input in processed:
			queued_inputs.erase(input)
		processed.clear()
		return

	var current_time = get_current_time()

	# Visual cue spawning loop
	var visual_search_start = max(0, last_visual_index - 20)
	for i in range(visual_search_start, timestamps.size()):
		var note = timestamps[i]
		if note.get("visual_spawned", false):
			continue
			
		if note["time"] <= current_time + (look_ahead_time / 1000.0):
			note["visual_spawned"] = true
			note["visual_cue"] = spawn_visual_cue(note)
		elif note["time"] > current_time + (look_ahead_time / 1000.0):
			last_visual_index = i
			break

	var search_start = max(0, last_search_index - 20)
	for i in range(search_start, timestamps.size()):
		var note = timestamps[i]

		if note["matched"]:
			continue
		
		if note["time"] < current_time - GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.OK]:
			note["matched"] = true
			if note.has("visual_cue") and is_instance_valid(note["visual_cue"]):
				note["visual_cue"].queue_free()
			miss += 1
			update_score(GlobalDefinitions.MISS)
		elif note["time"] > current_time + GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.OK]:
			last_search_index = i
			break

	for input in queued_inputs:
		process_input(input, current_time)
		processed.append(input)

	for input in processed:
		queued_inputs.erase(input)

	processed.clear()

func spawn_visual_cue(note: Dictionary) -> Node3D:
	if not e_drum_kit.has_node(note["type"]):
		return null
	var drum_node = e_drum_kit.get_node(note["type"])
	var visual_cue = VisualCue.new()
	drum_node.add_child(visual_cue)
	visual_cue.setup(note["time"], audio_player, look_ahead_time / 1000.0)
	return visual_cue

func process_input(input: Dictionary, current_time: float) -> void:
	var input_type = input["type"]
	var candidates = find_nearby_notes(current_time, GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.OK])

	var best_match = find_best_match(candidates, input_type, current_time)

	if best_match:
		var delta = current_time - best_match["time"]
		var hit_quality = evaluate_hit(delta)
		best_match["matched"] = true
		if best_match.has("visual_cue") and is_instance_valid(best_match["visual_cue"]):
			best_match["visual_cue"].queue_free()
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
		if combo > best_combo:
			best_combo = combo
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
		perfect += 1
		return GlobalDefinitions.PERFECT
	elif abs_delta <= GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.GREAT]:
		great += 1
		return GlobalDefinitions.GREAT
	elif abs_delta <= GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.GOOD]:
		good += 1
		return GlobalDefinitions.GOOD
	elif abs_delta <= GlobalDefinitions.HIT_WINDOWS[GlobalDefinitions.OK]:
		ok += 1
		return GlobalDefinitions.OK
	else:
		miss += 1
		return GlobalDefinitions.MISS

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "intro":
		return

	input_handler.setup_input_device()
	input_handler.enable_input_device()
	
func restart():
	music_resume_position = 0
	countdown_timer = 0.0
	is_game_paused = true
	if countdown_label:
		countdown_label.text = ""
	score = 0
	combo = 0
	best_combo = 0
	perfect = 0
	great = 0
	good = 0
	ok = 0
	miss = 0
	last_search_index = 0
	last_visual_index = 0
	queued_inputs.clear()
	
	for i in range(timestamps.size()):
		timestamps[i]["matched"] = false
		timestamps[i]["visual_spawned"] = false
		if timestamps[i].has("visual_cue") and is_instance_valid(timestamps[i]["visual_cue"]):
			timestamps[i]["visual_cue"].queue_free()
		
	game_overlay.restart()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_jump_to_end") and audio_player.stream:
		var target_time = max(0.0, audio_player.stream.get_length() - 10.0)
		if audio_player.playing:
			audio_player.play(target_time)
		else:
			music_resume_position = target_time

func hide_keybidingHud():
	$KeyboardOverlay.visible = false
