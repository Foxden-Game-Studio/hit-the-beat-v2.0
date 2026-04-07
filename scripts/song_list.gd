extends Control

var song_dir = "res://songs/"
var song_list_item: PackedScene = load("res://scenes/song_list_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_songs()
	$input_settings/input_device.select(GlobalSettings.input_device)

func load_songs():
	var songs = DirAccess.open(song_dir)

	if not songs:
		printerr("Failed to open song directory!")

	for song in songs.get_files():
		if song.ends_with(".json"):
			var file_content = FileAccess.get_file_as_string(song_dir + song)
			var song_data = JSON.parse_string(file_content)

			if song_data == null:
				printerr("Failed to parse json file: ", song)
				continue

			var new_song_list_item = song_list_item.instantiate()
			new_song_list_item.set_info(song_data["song_name"], song_data["difficulty"])
			new_song_list_item.connect("pressed", _on_song_button_pressed.bind(song_dir + song))

			$song_list/song_list.add_child(new_song_list_item)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_song_button_pressed(song: String) -> void:
	GlobalSettings.selected_song = song


func _on_input_device_item_selected(index: int) -> void:
	GlobalSettings.input_device = index
