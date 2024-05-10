extends CharacterBody2D

enum GhostState{SCATTER, CHASE, RUN_AWAY}

signal direction_change(current_direction: String)

var direction = null
var current_state: GhostState
var scatter_index: int = -1

@export var speed = 150
@export var target_array: Array[Marker2D]
@export var tile_map: MazeTileMap
@export var agent: NavigationAgent2D
@export var color: Color

@onready var pacman = $"../../../pacman"
@onready var scatter_timer = $ScatterTime
@onready var update_chasing_target_position_timer = $UpdateChasingTargetPositionTimer
@onready var run_away_timer = $RunAwayTimer
@onready var recover_from_run_away = $RecoverFromRunAway
@onready var body = $body
@onready var eyes = $eyes

func _ready():
	agent.path_desired_distance = 4.0
	agent.target_desired_distance = 4.0
	#agent.target_reached.connect(on_position_reached)
	
	#update_chasing_target_position_timer.start()
	scatter_timer.start()
	current_state = GhostState.SCATTER
	
	call_deferred("actor_setup")
	
func actor_setup():	
	await get_tree().physics_frame
	set_movement_target(target_array[scatter_index].position)
	
func set_movement_target(target: Vector2):
	agent.target_position = target
	
	
func _physics_process(delta):
	if agent.is_navigation_finished() and current_state == GhostState.SCATTER:
		set_movement_target(target_array[scatter_index].position)
		if scatter_index >= (target_array.size()-1): scatter_index = 0
		else: scatter_index += 1
	elif agent.is_navigation_finished() and current_state == GhostState.RUN_AWAY: run_away_path()
	elif agent.is_navigation_finished() and current_state == GhostState.CHASE: return
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = agent.get_next_path_position()
	
	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * speed
	
	calculate_direction(new_velocity)
	velocity = new_velocity
	move_and_slide()

func calculate_direction(velocity: Vector2):
	var current_direction
	if velocity.y < (-speed+10): current_direction = "up"
	elif velocity.y > (speed-10): current_direction = "down"
	elif velocity.x < (-speed+10): current_direction = "left"
	elif velocity.x > (speed-10): current_direction = "right"
	
	if current_direction != direction:
		direction = current_direction
		direction_change.emit(direction)


func _on_scatter_time_timeout():
	update_chasing_target_position_timer.start()
	current_state = GhostState.CHASE

func _on_update_chasing_target_position_timer_timeout():
	agent.target_position = pacman.position

func run_away():
	current_state = GhostState.RUN_AWAY
	
	body.run_away()
	eyes.hide()
	
	run_away_timer.start()
	recover_from_run_away.stop()
	scatter_timer.stop()
	update_chasing_target_position_timer.stop()
	
	run_away_path()

func run_away_path():
	var empty_cell_position = tile_map.get_random_empry_cell_position()
	agent.target_position = empty_cell_position

func _on_run_away_timer_timeout():
	body.recover_from_run_away()
	recover_from_run_away.start()

func _on_recover_from_run_away_timeout():
	current_state = GhostState.CHASE
	update_chasing_target_position_timer.start()
	eyes.show()
	body.move()
