extends Node

signal game_over

var player: Player
var player_position: Vector2
var is_game_over: bool = false

var time_elapsed: float = 0.0
var time_elapsed_string: String
var minutes:int = 0
var meat_counter: int = 0
var gold_counter: int = 0
var monsters_defeated_counter: int = 0

var highscore: int = 0

func _ready():
	load_highscore()

func _process(delta):
	time_elapsed += delta
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds:int = time_elapsed_in_seconds % 60
	minutes = time_elapsed_in_seconds / 60.0
	
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]

func end_game():
	if is_game_over: return
	is_game_over = true
	var total_score = calculate_total_score()
	if total_score > highscore:
		highscore = total_score
		save_highscore(highscore)
	game_over.emit()

func calculate_total_score() -> int:
	return (gold_counter * 10) + monsters_defeated_counter + (minutes * 50)

func reset():
	player = null
	player_position = Vector2.ZERO
	is_game_over = false
	time_elapsed = 0.0
	time_elapsed_string = "00:00"
	meat_counter = 0
	gold_counter = 0
	monsters_defeated_counter = 0
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)

func save_highscore(score: int):
	var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	file.store_string(str(score))
	file.close()

func load_highscore():
	var file = FileAccess.open("user://highscore.save", FileAccess.READ)
	if file:
		highscore = int(file.get_as_text())
		file.close()
	else:
		highscore = 0
