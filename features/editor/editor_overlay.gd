extends Control

@onready var game = $/root/Game
@onready var record_button = $record_button
@onready var count_label: Label = $HBoxContainer/count
var record_button_tween: Tween

func _ready():
	record_button.pivot_offset = Vector2(record_button.size/2)
	record_button.expand_icon = true

func _on_record_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		start_pulsing()
		game.start_recording()
	else:
		stop_pulsing()
		game.stop_recording()

func start_pulsing():
	record_button_tween = create_tween().set_loops()

	record_button_tween.tween_property(record_button, "scale", Vector2(0.8, 0.8), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	record_button_tween.tween_property(record_button, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func stop_pulsing():
	if record_button_tween:
		record_button_tween.kill()

	var reset_tween = create_tween()
	reset_tween.tween_property(record_button, "scale", Vector2(1.0, 1.0), 0.2)

func _on_back_button_pressed() -> void:
	record_button.button_pressed = false
	game.return_to_menu()

func set_count_label(count: int) -> void:
	count_label.text = String.num_int64(count)

func _on_check_button_toggled(toggled_on: bool) -> void:
	game.overwrite_timestamps = toggled_on
