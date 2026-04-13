extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $".."
@onready var viewport: SubViewport = $"../SubViewport"

func _input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:	
	var local_pos = mesh_instance.to_local(event_position)
	var mesh_size = mesh_instance.mesh.size

	var x = (local_pos.x / mesh_size.x) + 0.5
	var y = (local_pos.z / mesh_size.y) + 0.5

	var viewport_pos = Vector2(x * viewport.size.x, y * viewport.size.y)

	event.position = viewport_pos
	event.global_position = viewport_pos
	viewport.push_input(event)
