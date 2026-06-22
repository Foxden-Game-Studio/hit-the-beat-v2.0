extends HBoxContainer

func set_info(player: String, score: String, place: String):
	$player.text = player
	$score.text = score
	$place.text = place

	update_minimum_size()
