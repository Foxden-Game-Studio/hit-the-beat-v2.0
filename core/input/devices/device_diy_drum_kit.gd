extends Node

signal input(drum: String)

var udp: PacketPeerUDP

func _ready() -> void:
	udp = PacketPeerUDP.new()
	var err = udp.bind(5005)
	if err == OK:
		print("[DIY Drum Kit Device] Listening on port 5005 for UDP inputs.")
	else:
		print("[DIY Drum Kit Device] Failed to bind to port 5005. Error code: ", err)

func _process(_delta: float) -> void:
	if udp != null and udp.get_available_packet_count() > 0:
		var packet: PackedByteArray = udp.get_packet()
		var drum_name: String = packet.get_string_from_utf8()
		
		# Validate that it's a known drum
		if _is_valid_drum(drum_name):
			input.emit(drum_name)
		else:
			print("[DIY Drum Kit Device] Unknown drum received: ", drum_name)

func _is_valid_drum(drum_name: String) -> bool:
	return drum_name in [
		GlobalDefinitions.Drum.rack_tom_1,
		GlobalDefinitions.Drum.rack_tom_2,
		GlobalDefinitions.Drum.floor_tom_1,
		GlobalDefinitions.Drum.floor_tom_2,
		GlobalDefinitions.Drum.snare,
		GlobalDefinitions.Drum.ride,
		GlobalDefinitions.Drum.crash_cymbal_1,
		GlobalDefinitions.Drum.crash_cymbal_2,
		GlobalDefinitions.Drum.hi_hat_1,
		GlobalDefinitions.Drum.hi_hat_2,
		GlobalDefinitions.Drum.bass
	]
