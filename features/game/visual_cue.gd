extends Node3D

var target_time: float
var audio_player: AudioStreamPlayer3D
var look_ahead_time: float = 1.5
var ring_mesh: MeshInstance3D
var initial_scale: float = 2.5
var final_scale: float = 1.0

func setup(p_target_time: float, p_audio_player: AudioStreamPlayer3D, p_look_ahead_time: float):
	target_time = p_target_time
	audio_player = p_audio_player
	look_ahead_time = p_look_ahead_time
	
	# Create a TorusMesh
	ring_mesh = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.95
	torus.outer_radius = 1
	# We might need to rotate the torus so it lies flat on the drum.
	# Often drums have their surface along the XZ plane (Y is up).
	# Torus by default is on the XZ plane.
	ring_mesh.mesh = torus
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.741, 0.0, 0.162, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.8, 1.0)
	mat.emission_energy_multiplier = 2.0
	torus.material = mat
	
	add_child(ring_mesh)
	position = Vector3(0, 0.25, 0)
	scale = Vector3(initial_scale, initial_scale, initial_scale)

func _process(_delta):
	if not is_instance_valid(audio_player) or not audio_player.playing:
		queue_free()
		return
	
	var current_time = audio_player.get_playback_position()
	var time_left = target_time - current_time
	
	if time_left < -0.1 or time_left > look_ahead_time + 1.0: # Give a small margin after the hit, and destroy if restarted
		queue_free()
		return
		
	# time_left goes from look_ahead_time down to 0
	# progress goes from 0 to 1
	var progress = 1.0 - (time_left / look_ahead_time)
	progress = clamp(progress, 0.0, 1.0)
	
	var current_scale = lerp(initial_scale, final_scale, progress)
	scale = Vector3(current_scale, current_scale, current_scale)
	
	# Fade in at the beginning and stay solid
	var mat = ring_mesh.mesh.material as StandardMaterial3D
	if mat:
		mat.albedo_color.a = clamp(progress * 2.0, 0.0, 1.0)
