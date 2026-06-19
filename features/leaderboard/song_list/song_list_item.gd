extends Button

func set_info(song_title: String):
	$details/title.text = song_title

	update_minimum_size()
