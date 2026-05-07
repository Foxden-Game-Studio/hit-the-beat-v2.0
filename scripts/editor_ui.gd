extends Control

@onready var song_title_edit = $song_details/song_title/LineEdit
@onready var song_audio_edit = $song_details/song_audio/HBoxContainer/LineEdit
@onready var song_difficulty = $song_details/song_difficulty/OptionButton
@onready var timestamp_list = $song_timestamps/ScrollContainer/VBoxContainer/VBoxContainer
@onready var timestamp_template: PackedScene = load("res://scenes/editor_ui_list_item.tscn")

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
	pass
	

func show_error(e: String) -> void:
	$error_label.text = tr("error") + e
	$error_label.visible = true
	$error_acknowledged_button.visible = true

func _on_browse_files_button_pressed() -> void:
	$FileDialog.visible = true

func _on_file_dialog_file_selected(path: String) -> void:
	$song_details/song_audio/LineEdit.text = path


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
	pass # Replace with function body.
