extends Button

func set_info(song_title: String, difficulty: String, timestamps: int):
	$details/title.text = song_title
	$details/difficulty.text = tr("difficulty_" + difficulty)
	$details/timestamp_count.text = String.num_int64(timestamps)

	update_minimum_size()
