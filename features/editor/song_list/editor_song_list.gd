extends Control

var song_dir = GlobalDefinitions.USER_SONGS_DIR
var song_list_item: PackedScene = load("res://features/editor/song_list/editor_song_list_item.tscn")

var loading_screen: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_songs()
	$settings/input_settings/input_device.select(GlobalSettings.input_device)
	loading_screen = load("res://features/loading_screen/loading_screen.tscn")

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
			new_song_list_item.set_info(song_data["song_name"], song_data["difficulty"], song_data["timestamps"].size())
			new_song_list_item.connect("pressed", _on_song_button_pressed.bind(song_dir + song))

			$song_list/song_list.add_child(new_song_list_item)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://features/main_menu/main_menu.tscn")

func _on_song_button_pressed(song: String) -> void:
	GlobalSettings.selected_song = song
	GlobalSettings.new_song = false
	var instance = loading_screen.instantiate()
	instance.set_to_load_scene("res://features/editor/editor.tscn")
	instance.connect("scene_loading_finished", _on_loading_finished)
	get_tree().root.add_child(instance)
	instance.start_loading()

func _on_loading_finished(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)

func _on_input_device_item_selected(index: int) -> void:
	GlobalSettings.input_device = index


func _on_create_button_pressed() -> void:
	GlobalSettings.new_song = true
	var instance = loading_screen.instantiate()
	instance.set_to_load_scene("res://features/editor/editor.tscn")
	instance.connect("scene_loading_finished", _on_loading_finished)
	get_tree().root.add_child(instance)
	instance.start_loading()
