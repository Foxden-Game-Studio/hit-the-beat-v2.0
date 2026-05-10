extends Node3D

@onready var editor_ui = $menu_wall/SubViewport/EditorUi
@onready var anim_player: AnimationPlayer = $anim_player

var song = ""
var song_title = ""
var song_audio_path = ""
var difficulty = ""
var timestamps = []
var timestamp_template = {"time": 0, "type": ""}
var recording = false

func _ready() -> void:
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
	if not recording:
		return

func start_recording() -> void:
	anim_player.play("record")
	recording = true
