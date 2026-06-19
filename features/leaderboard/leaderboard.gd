extends Control

var player_list_item: PackedScene = load("res://features/leaderboard/player_list_item.tscn")

var leaderboard_dir = GlobalDefinitions.USER_LEADERBOARD_DIR
var song = GlobalSettings.selected_song

func _ready() -> void:
	load_leaderboard()

func load_leaderboard():
	var leaderboard
	var leaderboard_dir = DirAccess.open(GlobalDefinitions.USER_LEADERBOARD_DIR)
	
	if not leaderboard_dir:
		DirAccess.make_dir_absolute(GlobalDefinitions.USER_LEADERBOARD_DIR)
		leaderboard_dir = DirAccess.open(GlobalDefinitions.USER_LEADERBOARD_DIR)
	
	var song_filename = song.get_file()
	for tmp_leaderboard in leaderboard_dir.get_files():
		if tmp_leaderboard == song_filename:
			leaderboard = tmp_leaderboard
			break
			
	if not leaderboard:
		printerr("No leaderboard found for selected song")
		return
		
	var leaderboard_conten = JSON.parse_string(FileAccess.get_file_as_string(GlobalDefinitions.USER_LEADERBOARD_DIR + leaderboard))
	
	for player in leaderboard_conten["leaderboard"]:
		var new_player_list_item = player_list_item.instantiate()
		new_player_list_item.set_info(player["player"], String.num_int64(player["score"]))
		$player_list/player_list.add_child(new_player_list_item)
		
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://features/leaderboard/song_list/song_list.tscn")
