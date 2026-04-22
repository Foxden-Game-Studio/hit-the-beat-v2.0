extends Node

signal input(drum: String)

func pitch_to_drum(pitch: int) -> String:
	match  pitch:
		41: return "Floor Tom 2"
		43: return "Floor Tom 1"
		45: return "Rack Tom 2"
		48: return "Rack Tom 1"
		38: return "Snare Drum"
		51, 53, 59: return "Ride"
		57: return "Crash Cymbal 2"
		49: return "Crash Cymbal 1"
		46: return "Hi-Hat 1"
		36: return "Bass Drum"
		42: return "Hi-Hat 2"
		_: return ""

func _input(event: InputEvent) -> void:
	if event == InputEventMIDI:
		_process_midi_input(event)

func _process_midi_input(midi_event: InputEventMIDI) -> void:
	match midi_event.message:
		248: pass
		_:
			var drum = pitch_to_drum(midi_event.pitch)
			if !drum.is_empty():
				input.emit(drum)
