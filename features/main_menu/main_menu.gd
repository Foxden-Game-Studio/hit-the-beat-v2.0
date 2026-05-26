extends Control

@onready var main_menu: Control = $main_menu_control
@onready var mode_select: Control = $mode_select_control

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://features/settings/settings.tscn")

func _on_start_button_pressed() -> void:
	main_menu.visible = !main_menu.visible
	mode_select.visible = !mode_select.visible

func _on_quit_button_pressed() -> void:
	get_tree().quit(0)

func _on_editor_pressed() -> void:
	get_tree().change_scene_to_file("res://features/editor/song_list/editor_song_list.tscn")

func _on_normal_pressed() -> void:
	get_tree().change_scene_to_file("res://features/game/song_list/song_list.tscn")

func _on_back_pressed() -> void:
	main_menu.visible = !main_menu.visible
	mode_select.visible = !mode_select.visible

func _ready() -> void:
	sync_songs_to_user_dir()

func sync_songs_to_user_dir() -> void:
	var source_path = "res://data/songs/"
	var dest_path = GlobalDefinitions.USER_SONGS_DIR

	if not DirAccess.dir_exists_absolute(dest_path):
		DirAccess.make_dir_absolute(dest_path)

	var dir = DirAccess.open(source_path)
	if dir:
		for file in dir.get_files():
			if not file.ends_with(".import"): 
				var full_source = source_path + file
				var full_dest = dest_path + file

				if not FileAccess.file_exists(full_dest):
					DirAccess.copy_absolute(full_source, full_dest)
					if file.ends_with(".mp3"):
						print("Exported default song audio: ", file)
					elif file.ends_with(".json"):
						print("Exported default song config: ", file)
					else:
						print("Exported default song file with unknown extension: ", file)
	else:
		print("Error: Could not find the source songs folder in res://")
