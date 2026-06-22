extends Control

@onready var game: Node3D = $"/root/Game"
@onready var anim_player: AnimationPlayer = $"/root/Game/anim_player"
@onready var game_statistics_screen = $"game_statistics"
@onready var game_menu_screen = $"game_menu"
@onready var score_label = $"game_statistics/VBoxContainer/score_HBoxContainer/score"
@onready var combo_label = $"game_statistics/VBoxContainer/combo_HBoxContainer/combo"
@onready var play_pause_button: Button = $"game_statistics/play_pause_button"
@onready var song_label: Label = $"game_statistics/song_title"
@onready var end_screen: Control = $EndScreen
@onready var mode_label: Label = $game_statistics/mode
@onready var mode_button: Button = $game_statistics/mode_switch
@onready var song_progress_bar: ProgressBar = $game_statistics/ProgressBar

var play_icon = load("res://assets/icons/play_arrow_100dp_E3E3E3_FILL0_wght400_GRAD0_opsz48.svg")
var pause_icon = load("res://assets/icons/pause_100dp_E3E3E3_FILL0_wght400_GRAD0_opsz48.svg")

func _ready() -> void:
	song_progress_bar.min_value = 0.0
	song_progress_bar.max_value = 1.0

func _process(_delta: float) -> void:
	if game.listen_first:
		mode_label.text = TranslationServer.translate("mode") + ": " + TranslationServer.translate("listening")
	elif not game.listen_first:
		mode_label.text = TranslationServer.translate("mode") + ": " + TranslationServer.translate("playing")
		
	mode_button.disabled = not game.is_game_paused or game.music_resume_position != 0
	
	if not game.is_game_paused:
		var duration = game.audio_player.stream.get_length()
		if duration > 0:
			song_progress_bar.value = game.audio_player.get_playback_position() / duration

func set_song_title(song: String) -> void:
	song_label.text = song

func set_score(score: int) -> void:
	score_label.text = String.num_int64(score)

func set_combo(combo: int) -> void:
	combo_label.text = String.num_int64(combo)

func _on_menu_button_pressed() -> void:
	play_pause_button.button_pressed = false
	anim_player.play("toggle_game_menu")
	game_statistics_screen.visible = false
	game_menu_screen.visible = true


func _on_resume_button_pressed() -> void:
	anim_player.play_backwards("toggle_game_menu")
	game_menu_screen.visible = false
	game_statistics_screen.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://features/main_menu/main_menu.tscn")


func _on_pause_play_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		game.is_game_paused = false
		if not game.audio_player.playing and game.countdown_timer <= 0.0:
			game.countdown_timer = 3.0
		elif game.audio_player.playing and game.audio_player.stream_paused:
			game.countdown_timer = 3.0
		play_pause_button.icon = pause_icon
	elif not toggled_on:
		game.is_game_paused = true
		if game.audio_player.playing:
			game.audio_player.stream_paused = true
			game.music_resume_position = game.audio_player.get_playback_position()
		play_pause_button.icon = play_icon


func _on_audio_player_finished() -> void:
	anim_player.play("toggle_game_menu")
	game_statistics_screen.visible = false
	game_menu_screen.visible = false
	end_screen.visible = true
	end_screen.set_score_values()
	
func restart():
	if end_screen.visible:
		anim_player.play_backwards("toggle_game_menu")
	game_statistics_screen.visible = true
	game_menu_screen.visible = false
	end_screen.visible = false
	
	set_score(0)
	set_combo(0)
	play_pause_button.set_pressed_no_signal(false)
	play_pause_button.icon = play_icon
	
func _on_mode_switch_pressed() -> void:
	game.listen_first =! game.listen_first


func _on_reset_button_pressed() -> void:
	game.restart()
