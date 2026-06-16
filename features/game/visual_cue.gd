extends Node3D

var target_time: float
var audio_player: AudioStreamPlayer3D
var look_ahead_time: float = 1.5
var ring_mesh: MeshInstance3D
var initial_height: float = 2.5
var final_height: float = 0.25

var game: Node3D

func setup(p_target_time: float, p_audio_player: AudioStreamPlayer3D, p_look_ahead_time: float):
	target_time = p_target_time
	audio_player = p_audio_player
	look_ahead_time = p_look_ahead_time
	game = get_node("/root/Game")
	
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
	mat.albedo_color = Color(0.9, 0.1, 0.1, 1.0) # Strong Red
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.0, 0.0) # Deep Red emission
	mat.emission_energy_multiplier = 2.5
	torus.material = mat
	
	add_child(ring_mesh)
	position = Vector3(0, initial_height, 0)
	scale = Vector3(1.0, 1.0, 1.0)

func _process(_delta):
	if not is_instance_valid(audio_player):
		queue_free()
		return
	if not audio_player.playing and game.countdown_timer <= 0.0:
		return
	
	var current_time = game.get_current_time()
	var time_left = target_time - current_time
	
	if time_left < -0.1 or time_left > look_ahead_time + 1.0: # Give a small margin after the hit, and destroy if restarted
		queue_free()
		return
		
	# time_left goes from look_ahead_time down to 0
	# progress goes from 0 to 1
	var progress = 1.0 - (time_left / look_ahead_time)
	progress = clamp(progress, 0.0, 1.0)
	
	var current_height = lerp(initial_height, final_height, progress)
	position = Vector3(0, current_height, 0)
	
	# Fade in at the beginning and stay solid
	var mat = ring_mesh.mesh.material as StandardMaterial3D
	if mat:
		mat.albedo_color.a = clamp(progress * 2.0, 0.0, 1.0)
