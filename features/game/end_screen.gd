extends Control

@export var game: Node3D

@export var player_name_edit: LineEdit
@export var save_leaderboard_button: Button

@export var score_label: Label
@export var best_combo_label: Label
@export var perfect_label: Label
@export var great_label: Label
@export var good_label: Label
@export var ok_label: Label
@export var miss_label: Label

var score: int = 0
var combo: int = 0
var best_combo: int = 0

var perfect: int = 0
var great: int = 0
var good: int = 0
var ok: int = 0
var miss: int = 0

var score_saved: bool = false

func set_score_values():
	score_saved = false
	score = game.score
	best_combo = game.best_combo

	perfect = game.perfect
	great = game.great
	good = game.good
	ok = game.ok
	miss = game.miss
	
	score_label.text = String.num_int64(score)
	best_combo_label.text = String.num_int64(best_combo)
	perfect_label.text = String.num_int64(perfect)
	great_label.text = String.num_int64(great)
	good_label.text = String.num_int64(good)
	ok_label.text = String.num_int64(ok)
	miss_label.text = String.num_int64(miss)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if score_saved or player_name_edit.text.is_empty():
		save_leaderboard_button.disabled = true
	else:
		save_leaderboard_button.disabled = false


func _on_restart_button_pressed() -> void:
	game.restart()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://features/main_menu/main_menu.tscn")


func _on_save_leaderboard_button_pressed() -> void:
	save_leaderboard()
	score_saved = true


func _on_view_leaderboard_button_pressed() -> void:
	get_tree().change_scene_to_file("res://features/leaderboard/leaderboard.tscn")

func save_leaderboard():
	var player_name: String = player_name_edit.text
	
	Helpers.save_leaderboard_entry(GlobalSettings.selected_song, player_name, score)
	GlobalSettings.last_player_name = player_name
	GlobalSettings.last_player_score = score
