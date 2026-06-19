extends Node

func load_audio_file(path: String) -> AudioStreamMP3:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var sound_data = file.get_buffer(file.get_length())

		var new_stream = AudioStreamMP3.new()
		new_stream.data = sound_data

		return new_stream
	else:
		printerr("Error: File not found at ", path)
		return null
		
func save_leaderboard_entry(leaderboard: String, player_name: String, score: int):
	var leaderboard_path = leaderboard.replace(GlobalDefinitions.USER_SONGS_DIR, GlobalDefinitions.USER_LEADERBOARD_DIR)
	
	var song_leaderboard: Dictionary
	if not FileAccess.file_exists(leaderboard_path):
		var song_details = JSON.parse_string(FileAccess.get_file_as_string(leaderboard))
		
		song_leaderboard = {
			"song_name": song_details["song_name"],
			"difficulty": song_details["difficulty"],
			"leaderboard": [{
				"player": player_name,
				"score": score
			}]
		}
	else:
		song_leaderboard = JSON.parse_string(FileAccess.get_file_as_string(leaderboard_path))
		
		song_leaderboard["leaderboard"].append({"player": player_name, "score": score})
	
	var file = FileAccess.open(leaderboard_path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(song_leaderboard, "  "))
		file.close()
	else:
		printerr("Failed to save leaderboard: stage: write to file")
