extends Node

signal input(drum: String)

func _ready() -> void:
	OS.open_midi_inputs()
	print("[MIDI Drum Kit Device] Initialized. Connected devices: ", OS.get_connected_midi_inputs())

func pitch_to_drum(pitch: int) -> String:
	match  pitch:
		41: return GlobalDefinitions.Drum.floor_tom_2
		43: return GlobalDefinitions.Drum.floor_tom_1
		45: return GlobalDefinitions.Drum.rack_tom_2
		48: return GlobalDefinitions.Drum.rack_tom_1
		38: return GlobalDefinitions.Drum.snare
		51, 53, 59: return GlobalDefinitions.Drum.ride
		57: return GlobalDefinitions.Drum.crash_cymbal_2
		49: return GlobalDefinitions.Drum.crash_cymbal_1
		46: return GlobalDefinitions.Drum.hi_hat_1
		36: return GlobalDefinitions.Drum.bass
		42: return GlobalDefinitions.Drum.hi_hat_2
		_: return GlobalDefinitions.Drum.undefined

func _input(event: InputEvent) -> void:
	if event is InputEventMIDI:
		_process_midi_input(event)

func _process_midi_input(midi_event: InputEventMIDI) -> void:
	if midi_event.message == MIDI_MESSAGE_NOTE_ON and midi_event.velocity > 0:
		var drum = pitch_to_drum(midi_event.pitch)
		if !drum.is_empty():
			input.emit(drum)
		else:
			print("[MIDI Drum Kit Device] Note hit was ignored. Pitch: ", midi_event.pitch, " is not mapped to any drum.")
