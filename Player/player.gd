class_name Player
extends CharacterBody2D
@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage:int = 2
@export_category("Ritual")
@export var ritual_damage:int = 5
@export var ritual_interval:float = 30
@export var ritual_scene: PackedScene
@export_category("Life")
@export var health: int = 100
@export var death_prefab: PackedScene
@export var max_health: int = 100

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sword_area: Area2D = $SwordArea

@onready var hitbox_area: Area2D = $HitBoxArea

@onready var sprite: Sprite2D = $Sprite2D

@onready var health_bar: ProgressBar = $HealthBar



var isRunning: bool = false
var isAttacking: bool = false
var comboAttack: bool = false
var was_running: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var input_vector: Vector2 = Vector2(0,0)
var attack_direction: Vector2
var ritual_cooldown: float = 0.0

signal meat_collected(value: int)
signal gold_collected(value: int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value:int): GameManager.meat_counter +=1)
	gold_collected.connect(func(value:int): GameManager.gold_counter += 1)
func _process(delta: float):
	GameManager.player_position = position
	read_input()
	
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attackCombo()
	if Input.is_action_just_pressed("attack"):
		attack()



			
	play_run_idle_animation()
	rotate_sprite()

	update_hitbox_detection(delta)
	
	update_ritual(delta)
	
	health_bar.max_value = max_health
	health_bar.value = health
	
func _physics_process(delta):	
	var target_velocity = input_vector * speed * 100
	if isAttacking:
		target_velocity *= 0.0
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

func read_input():
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	
	was_running = isRunning
	isRunning = not input_vector.is_zero_approx()
	
func attack():
	if isAttacking:
		return
	if input_vector.y > 0:
		attack_direction = Vector2.DOWN
		animation_player.play("attack_down_1")
	elif  input_vector.y < 0:
		attack_direction = Vector2.UP
		animation_player.play("attack_up_1")
	elif sprite.flip_h:
		attack_direction = Vector2.LEFT
		animation_player.play("attack_side_1")
	else:
		attack_direction = Vector2.RIGHT
		animation_player.play("attack_side_1")

		
	attack_cooldown = 0.6
	isAttacking = true	



func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product >= 0.7:
				enemy.damage(sword_damage)
			

func update_hitbox_detection(delta:float):
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	hitbox_cooldown = 0.5
	
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
		
func play_run_idle_animation():
	if not isAttacking:
		if was_running != isRunning:
			if isRunning:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite():
	if input_vector.x > 0 and isAttacking==false:
		sprite.flip_h = false
	elif input_vector.x < 0 and isAttacking==false :
		sprite.flip_h = true

func update_attack_cooldown(delta: float):
	if isAttacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			sword_damage = 2
			isAttacking = false
			comboAttack = false
			isRunning = false
			animation_player.play("idle")
			

func damage(amount: int):
	if health <= 0: return
	
	health -= amount
	print("Player Receive damage ", amount, ". Health left = ", health)
	
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	if health <= 0:
		die()


func heal(amount: int) -> int:
	print("Heal")
	health += amount
	if health > max_health:
		health = max_health
	return health

func die():
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	print("Player Morreu!!!")
	
	queue_free()
	
func update_ritual(delta: float):
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	

func attackCombo():
	if isAttacking && comboAttack == false && attack_cooldown<=0.14:
		attack_cooldown = 0.4
		sword_damage = 3
		animation_player.play("attack_side_2")
		comboAttack = true
	



