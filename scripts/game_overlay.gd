extends Control

@onready var game: Node3D = $"/root/Game"
@onready var anim_player: AnimationPlayer = $"/root/Game/anim_player"
@onready var game_statistics_screen = $"game_statistics"
@onready var game_menu_screen = $"game_menu"
@onready var score_label = $"game_statistics/VBoxContainer/score_HBoxContainer/score"
@onready var combo_label = $"game_statistics/VBoxContainer/combo_HBoxContainer/combo"
@onready var play_pause_button: Button = $"game_statistics/play_pause_button"

var play_icon = load("res://assets/icons/play_arrow_100dp_E3E3E3_FILL0_wght400_GRAD0_opsz48.svg")
var pause_icon = load("res://assets/icons/pause_100dp_E3E3E3_FILL0_wght400_GRAD0_opsz48.svg")

func set_score(score: int) -> void:
	score_label.text = String.num_int64(score)

func set_combo(combo: int) -> void:
	combo_label.text = String.num_int64(combo)

func _on_menu_button_pressed() -> void:
	anim_player.play("toggle_game_menu")
	game_statistics_screen.visible = false
	game_menu_screen.visible = true


func _on_resume_button_pressed() -> void:
	anim_player.play_backwards("toggle_game_menu")
	game_menu_screen.visible = false
	game_statistics_screen.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_pause_play_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		game.audio_player.play(game.music_resume_position)
		play_pause_button.icon = pause_icon
	elif not toggled_on:
		game.music_resume_position = game.audio_player.get_playback_position()
		game.audio_player.stop()
		play_pause_button.icon = play_icon
