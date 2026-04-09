extends Node

signal input(drum: String)

func pitch_to_name(pitch: int) -> String:
	match  pitch:
		41: return "tom_4"
		43: return "tom_3"
		45: return "tom_2"
		48: return "tom_1"
		38: return "snare"
		51, 53, 59: return "ride"
		57: return "crash_2"
		49: return "crash_1"
		46: return "hi_hat"
		36: return "bass"
		42: return "hi_hat_down"
		_: return ""

func _input(event: InputEvent) -> void:
	if event == InputEventMIDI:
		_process_midi_input(event)

func _process_midi_input(midi_event: InputEventMIDI) -> void:
	match midi_event.message:
		248: pass
		_:	
			var drum = pitch_to_name(midi_event.pitch)
			if !drum.is_empty():
				input.emit(drum)
			
