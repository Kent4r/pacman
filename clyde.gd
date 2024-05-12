extends CharacterBody2D

enum GhostState{SCATTER, CHASE, RUN_AWAY, EATEN, START_HOME, BIT_SCARED, BEATEN}

signal direction_change(current_direction: String)

var direction = null
var current_state: GhostState
var scatter_index: int = 0
var home_index: int = 0

@export var difficulty: int = 1
@export var eaten_speed = 300
@export var speed = 150
@export var target_array: Array[Marker2D]
@export var at_home_targets: Array[Marker2D]
@export var tile_map: MazeTileMap
@export var agent: NavigationAgent2D
@export var color: Color
@export var points_manager: PointsManager
@export var is_starting_at_home: bool
@export var start: Marker2D

@onready var pacman = $"../../../pacman"
@onready var scatter_timer = $ScatterTime
@onready var update_chasing_target_position_timer = $UpdateChasingTargetPositionTimer
@onready var run_away_timer = $RunAwayTimer
@onready var recover_from_run_away = $RecoverFromRunAway
@onready var body = $body
@onready var eyes = $eyes
@onready var points_label = $PointsLabel
@onready var at_home_timer = $AtHomeTimer
@onready var eat_ghost_sp = $"../../../SoundPlayers/EatGhostSP"

func IS_SCARED(): return true if (current_state == GhostState.RUN_AWAY or current_state == GhostState.BIT_SCARED) else false

func _ready():
	current_state = GhostState.RUN_AWAY
	position = start.position
	scatter_timer.stop()
	update_chasing_target_position_timer.stop()
	run_away_timer.stop()
	recover_from_run_away.stop()
	at_home_timer.stop()
	scatter_index = 0
	home_index = 0
	body.move()
	body.show()
	eyes.show()
	agent.path_desired_distance = 4.0
	agent.target_desired_distance = 4.0
	#agent.target_reached.connect(on_position_reached)
	
	if is_starting_at_home: start_at_home()
	else:
		scatter_index -= 1
		scatter_timer.start()
		current_state = GhostState.SCATTER
		call_deferred("actor_setup")

func hide_from_UI():
	body.hide()
	eyes.hide()
	current_state = GhostState.BEATEN
	scatter_timer.stop()
	update_chasing_target_position_timer.stop()
	run_away_timer.stop()
	recover_from_run_away.stop()
	at_home_timer.stop()

func scatter():
	scatter_timer.start()
	current_state = GhostState.SCATTER
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	agent.target_position = target_array[scatter_index].position
	
func set_movement_target(target: Vector2):
	agent.target_position = target

func start_at_home():
	current_state = GhostState.START_HOME
	at_home_timer.start()
	agent.target_position = at_home_targets[home_index].position

func _on_at_home_timer_timeout():
	if current_state == GhostState.BIT_SCARED: current_state = GhostState.RUN_AWAY
	else: scatter()

func move_to_next_home_pos():
	home_index = 1 if home_index == 0 else 0
	agent.target_position = at_home_targets[home_index].position

func _physics_process(delta):
	if agent.is_navigation_finished() and current_state == GhostState.SCATTER:
		agent.target_position = target_array[scatter_index].position
		if scatter_index >= (target_array.size()-1): scatter_index = 0
		else: scatter_index += 1
	elif agent.is_navigation_finished() and current_state == GhostState.RUN_AWAY: run_away_path()
	elif agent.is_navigation_finished() and current_state == GhostState.CHASE: return
	elif agent.is_navigation_finished() and current_state == GhostState.EATEN: start_chasing_pacman()
	elif agent.is_navigation_finished() and current_state == GhostState.START_HOME: move_to_next_home_pos()
	elif agent.is_navigation_finished() and current_state == GhostState.BIT_SCARED: move_to_next_home_pos()
	elif current_state == GhostState.BEATEN: return
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = agent.get_next_path_position()
	
	var current_speed = (eaten_speed if current_state == GhostState.EATEN else speed)*difficulty
	if (current_state == GhostState.RUN_AWAY or current_state == GhostState.BIT_SCARED): current_speed *= 0.75
	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * current_speed
	
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

func start_chasing_pacman():
	update_chasing_target_position_timer.start()
	current_state = GhostState.CHASE
	eyes.show()
	body.show()
	body.move()

func _on_update_chasing_target_position_timer_timeout():
	agent.target_position = pacman.position

func run_away():
	if current_state == GhostState.EATEN:
		pass
	elif current_state == GhostState.START_HOME:
		current_state = GhostState.BIT_SCARED
		body.run_away()
		eyes.hide()
		run_away_timer.start()
		recover_from_run_away.stop()
		scatter_timer.stop()
		update_chasing_target_position_timer.stop()
	else:
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
	if current_state == GhostState.EATEN: pass
	else:
		current_state = GhostState.CHASE
		update_chasing_target_position_timer.start()
		eyes.show()
		body.move()

func get_eaten():
	eat_ghost_sp.play()
	current_state = GhostState.EATEN
	body.hide()
	eyes.show()
	points_label.show()
	points_label.text = str(points_manager.points_for_ghost_eaten)
	await points_manager.pause_on_ghost_eaten()
	points_label.hide()
	run_away_timer.stop()
	agent.target_position = at_home_targets[2].position

func _on_area_2d_body_entered(body):
	var player = body as Player
	if current_state == GhostState.RUN_AWAY or current_state == GhostState.BIT_SCARED:
		get_eaten()
	elif current_state == GhostState.EATEN: pass
	elif current_state == GhostState.SCATTER or current_state == GhostState.CHASE or current_state == GhostState.START_HOME:
		update_chasing_target_position_timer.stop()
		player.die()
	else: pass
