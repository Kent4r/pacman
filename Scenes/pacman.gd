extends CharacterBody2D

class_name Player

signal player_died()
signal player_restart()

#variables
var next_movement_direction = Vector2.ZERO
var movement_direction = Vector2.ZERO
var shape_query = PhysicsShapeQueryParameters2D.new()

#export variables
@export var speed_multiplier: int = 1
@export var speed = 150
@export var start: Marker2D
@export var lifes: int = 3
@export var pacman_death_sound: AudioStreamPlayer2D

#onready variables
@onready var direction_pointer = $DirectionPointer
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var power_pellet_sp = $"../SoundPlayers/PowerPelletSP"
@onready var ui = $"../UI"
@onready var pellets = $"../Pellets"

func _ready():
	shape_query.shape = collision_shape_2d.shape
	shape_query.collision_mask = 2
	
	reset_player()
	animation_player.play("default")

func reset_player():
	lifes-=1
	animation_player.play("default")
	position = start.position
	set_physics_process(true)
	get_tree().create_timer(0.1).timeout.connect(reset_collision)
	next_movement_direction = Vector2.ZERO
	movement_direction = Vector2.ZERO

func restart_game():
	position = start.position
	next_movement_direction = Vector2.ZERO
	movement_direction = Vector2.ZERO
	set_physics_process(true)
	animation_player.play("default")
	player_restart.emit()
	lifes+=1
	ui.update_lifes(1)
	pellets.restart_pellets()
	get_tree().create_timer(0.1).timeout.connect(reset_collision)

func reset_collision(): set_collision_layer_value(1, true)

func _physics_process(delta):
	get_input()
	
	if movement_direction == Vector2.ZERO:
		movement_direction = next_movement_direction
	if can_move_in_direction(next_movement_direction, delta):
		movement_direction = next_movement_direction
		
	velocity = movement_direction * speed * speed_multiplier
	move_and_slide()
	if movement_direction == Vector2.LEFT:
		rotation_degrees = 0
	elif movement_direction == Vector2.RIGHT:
		rotation_degrees = 180
	elif movement_direction == Vector2.DOWN:
		rotation_degrees = -90
	elif movement_direction == Vector2.UP:
		rotation_degrees = 90

func get_input():
	if Input.is_action_pressed("left"):
		next_movement_direction = Vector2.LEFT
	elif Input.is_action_pressed("right"):
		next_movement_direction = Vector2.RIGHT
	elif Input.is_action_pressed("down"):
		next_movement_direction = Vector2.DOWN
	elif Input.is_action_pressed("up"):
		next_movement_direction = Vector2.UP
	elif Input.is_action_pressed("stop"):
		next_movement_direction = Vector2.ZERO

func can_move_in_direction(dir: Vector2, delta: float) -> bool:
	shape_query.transform = global_transform.translated(dir * speed * speed_multiplier * delta * 2)
	var result = get_world_2d().direct_space_state.intersect_shape(shape_query)
	return result.size() == 0

func die():
	power_pellet_sp.stop()
	pacman_death_sound.play()
	set_collision_layer_value(1, false)
	animation_player.play("death")
	set_physics_process(false)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		if lifes>0:
			ui.update_lifes(-1)
			player_died.emit()
			reset_player()
		else: ui.game_lost()
