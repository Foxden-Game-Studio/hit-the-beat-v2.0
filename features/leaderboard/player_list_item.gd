extends HBoxContainer

func set_info(player: String, score: String):
	$player.text = player
	$score.text = score

	update_minimum_size()
