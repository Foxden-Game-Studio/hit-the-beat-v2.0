extends Button

func set_info(song_title: String, difficulty: String):
	$details/title.text = song_title
	$details/difficulty.text = tr("difficulty_" + difficulty)

	update_minimum_size()
