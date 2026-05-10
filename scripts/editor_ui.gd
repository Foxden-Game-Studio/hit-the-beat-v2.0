extends Control

@onready var song_title_edit = $song_details/song_title/LineEdit
@onready var song_audio_edit = $song_details/song_audio/HBoxContainer/LineEdit
@onready var song_difficulty = $song_details/song_difficulty/OptionButton
@onready var timestamp_list = $song_timestamps/ScrollContainer/VBoxContainer/VBoxContainer
@onready var timestamp_template: PackedScene = load("res://scenes/editor_ui_list_item.tscn")
@onready var game = $/root/Game

func setup_ui(title: String, audio: String, difficulty: String, timestamps: Array) -> void:
	song_title_edit.text = title
	song_audio_edit.text = audio
	
	var index
	match difficulty:
		"easy": index = 0
		"medium": index = 1
		"hard": index = 2
	
	song_difficulty.select(index)
	for timestamp in timestamps:
		var timestamp_row = timestamp_template.instantiate()
		timestamp_row.set_info(timestamp["time"], timestamp["type"])
		timestamp_row.get_node("del_button").connect("pressed", _on_del_button_pressed.bind(timestamp_row))
		timestamp_list.add_child(timestamp_row)

func save_song() -> void:
	print("Saving Song")
	var audio_path: String = song_audio_edit.text
	var file_name = audio_path.get_file()

	if not FileAccess.file_exists(GlobalDefinitions.USER_SONGS_DIR + file_name):
		print("File not found in User dir")
		print("Copying file to User dir...")
		DirAccess.copy_absolute(audio_path, GlobalDefinitions.USER_SONGS_DIR + file_name)
		audio_path = GlobalDefinitions.USER_SONGS_DIR + file_name

	var timestamps = []

	for item in timestamp_list.get_children():
		timestamps.append(item.get_info())
	
	var song_config = {
		"song_name": song_title_edit.text,
		"difficulty": song_difficulty.get_item_text(song_difficulty.selected).get_slice("_", 1),
		"audio_file": audio_path,
		"timestamps": timestamps,
	}

	var json_string = JSON.stringify(song_config, "  ")
	var save_file = audio_path.replace(".mp3", ".json")

	var file = FileAccess.open(save_file, FileAccess.WRITE)

	if file:
		file.store_string(json_string)
		file.close()
		print("Song saved successful!")
	else:
		print("Failed to save song: Stage: write to file")
	

func show_error(e: String) -> void:
	$error_label.text = tr("error") + e
	$error_label.visible = true
	$error_acknowledged_button.visible = true

func _on_browse_files_button_pressed() -> void:
	$FileDialog.visible = true

func _on_file_dialog_file_selected(path: String) -> void:
	song_audio_edit.text = path


func _on_error_acknowledged_button_pressed() -> void:
	$error_label.visible = false
	$error_acknowledged_button.visible = false
	
func _on_del_button_pressed(node) -> void:
	node.queue_free()

func _on_add_button_pressed() -> void:
	var timestamp_row = timestamp_template.instantiate()
	timestamp_row.get_node("del_button").connect("pressed", _on_del_button_pressed.bind(timestamp_row))
	timestamp_list.add_child(timestamp_row)


func _on_save_pressed() -> void:
	save_song()


func _on_save_quit_pressed() -> void:
	save_song()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_no_save_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_record_button_pressed() -> void:
	game.start_recording()
