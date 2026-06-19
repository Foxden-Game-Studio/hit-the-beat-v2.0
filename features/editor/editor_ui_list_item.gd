extends HBoxContainer

const DRUM_LOOKUP = [
	GlobalDefinitions.Drum.rack_tom_1,      # 0
	GlobalDefinitions.Drum.rack_tom_2,      # 1
	GlobalDefinitions.Drum.floor_tom_1,     # 2
	GlobalDefinitions.Drum.floor_tom_2,     # 3
	GlobalDefinitions.Drum.snare,           # 4
	GlobalDefinitions.Drum.ride,            # 5
	GlobalDefinitions.Drum.crash_cymbal_1,  # 6
	GlobalDefinitions.Drum.crash_cymbal_2,  # 7
	GlobalDefinitions.Drum.hi_hat_1,        # 8
	GlobalDefinitions.Drum.hi_hat_2,        # 9
	GlobalDefinitions.Drum.bass             # 10
]

func set_info(time: float, type: String):
	var drum
	match type:
		GlobalDefinitions.Drum.rack_tom_1: drum = 0
		GlobalDefinitions.Drum.rack_tom_2: drum = 1
		GlobalDefinitions.Drum.floor_tom_1: drum = 2
		GlobalDefinitions.Drum.floor_tom_2: drum = 3
		GlobalDefinitions.Drum.snare: drum = 4
		GlobalDefinitions.Drum.ride: drum = 5
		GlobalDefinitions.Drum.crash_cymbal_1: drum = 6
		GlobalDefinitions.Drum.crash_cymbal_2: drum = 7
		GlobalDefinitions.Drum.hi_hat_1: drum = 8
		GlobalDefinitions.Drum.hi_hat_2: drum = 9
		GlobalDefinitions.Drum.bass: drum = 10
		
	$LineEdit.text = String.num(time)
	$OptionButton.select(drum)
	
	update_minimum_size()
	
func get_info() -> Dictionary:
	var info = {
		"time": float($LineEdit.text),
		"type": DRUM_LOOKUP[$OptionButton.selected],
	}
	return info
