class_name GameOverUI
extends CanvasLayer

@onready var time_label: Label = %TimerLabel
@onready var monsters_label: Label = %MonstersLabel
@onready var gold_label: Label = %GoldLabel
@onready var points_label: Label = %PointsLabel
@onready var highscore_label: Label = %HighscoreLabel  # Adicione um Label no editor para o Highscore

func _ready():
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.monsters_defeated_counter)
	gold_label.text = str(GameManager.gold_counter)
	var total_score = (GameManager.gold_counter * 10) + (GameManager.monsters_defeated_counter) + (GameManager.minutes * 50)
	points_label.text = "Pontuação Total: " + str(total_score)
	highscore_label.text = "Highscore: " + str(GameManager.highscore)

func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()


func _on_button_pressed():
	restart_game()
