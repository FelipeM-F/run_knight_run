extends Node

@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 60.0
@export var enemeies_increase_rate: float = 30.0
@export var wave_duration: float = 20.0
@export var wave_intensity: float = 0.5

var timer: float = 0.0
func _process(delta):
	if GameManager.is_game_over: return
	
	timer += delta
	#Dificuldade linear
	var spawn_rate = initial_spawn_rate + enemeies_increase_rate*(timer/60)
	#Dificuldade em ondas
	var sin_wave = (sin(timer*TAU))/wave_duration
	var wave = remap(sin_wave, -1.0, 1.0, wave_intensity, 1)
	mob_spawner.enemies_per_minute = spawn_rate
	
	
