extends Node3D

func on_drum_hit(type: String, color: Color):
	var material: Material = get_node(type).get_active_material(0)
	var tween = create_tween()

	# Quickly ramp up the glow
	tween.tween_property(material, "shader_parameter/flash_color", color, 0.05)
	# Fade back to normal
	tween.tween_property(material, "shader_parameter/flash_color", Color.BLACK, 0.2)
