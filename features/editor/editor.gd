extends Node3D

@onready var editor_ui = $menu_wall/SubViewport/EditorUi
@onready var anim_player: AnimationPlayer = $anim_player
@onready var e_drum_kit = $"e-drum-kit"
@onready var overlay = $"MeshInstance3D/SubViewport/EditorOverlay"
@onready var input_handler = $input_handler
@onready var audio_player: AudioStreamPlayer3D = $audio_player

var song = ""
var song_title = ""
var song_audio_path = ""
var difficulty = ""
var timestamps = []
var timestamp_template = {"time": 0, "type": ""}
var recording = false
var overwrite_timestamps = false
var audio_resume_position = 0
var countdown_timer: float = 0.0
var countdown_label: Label

var queued_inputs = []

func _ready() -> void:
	input_handler.setup_input_device()

	countdown_label = Label.new()
	countdown_label.set_anchors_preset(Control.PRESET_CENTER)
	countdown_label.add_theme_font_size_override("font_size", 120)
	countdown_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	countdown_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	countdown_label.add_theme_constant_override("outline_size", 10)
	countdown_label.text = ""
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay.add_child(countdown_label)

	if GlobalSettings.new_song:
		return
	
	song = GlobalSettings.selected_song
	
	var file_contents = FileAccess.get_file_as_string(song)
	var json_file = JSON.parse_string(file_contents)
	
	if json_file == null:
		editor_ui.show_error("Failed to open song file")
		return
		
	song_title = json_file["song_name"]
	song_audio_path = json_file["audio_file"]
	difficulty = json_file["difficulty"]
	timestamps = json_file["timestamps"]
	
	editor_ui.setup_ui(song_title, song_audio_path, difficulty, timestamps)

func _process(_delta: float) -> void:
	var processed = []
	
	if countdown_timer > 0.0:
		countdown_timer -= _delta
		countdown_label.text = str(ceil(countdown_timer))
		if countdown_timer <= 0.0:
			countdown_timer = 0.0
			countdown_label.text = ""
			_start_recording_immediate()
		return
	
	if not recording:
		for input in queued_inputs:
			e_drum_kit.on_drum_hit(input["type"], Color.RED)
		queued_inputs.clear()
		return

	for input in queued_inputs:
		e_drum_kit.on_drum_hit(input["type"], Color.VIOLET)
		timestamps.append(input)
		processed.append(input)

	overlay.set_count_label(timestamps.size())

	for input in processed:
		queued_inputs.erase(input)

	processed.clear()

func setup_recording(audio_file: String, _timestamps: Array) -> void:
	var stream = Helpers.load_audio_file(audio_file)
	if stream:
		audio_player.stream = stream
	anim_player.play("record")
	timestamps = _timestamps
	input_handler.enable_input_device()

func start_recording():
	countdown_timer = 3.0

func _start_recording_immediate():
	if overwrite_timestamps:
		timestamps.clear()
	recording = true
	audio_player.play(audio_resume_position)

func stop_recording():
	recording = false
	audio_player.stream_paused = true
	audio_resume_position = audio_player.get_playback_position()

func return_to_menu() -> void:
	anim_player.play_backwards("record")
	editor_ui.update_timestamp_list(timestamps)
	audio_resume_position = 0
	input_handler.disable_input_device()
