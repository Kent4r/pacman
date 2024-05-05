extends CharacterBody2D

signal direction_change(current_direction: String)

var direction = null

@export var speed = 150
@export var target: Node2D
@export var agent: NavigationAgent2D
@export var color: Color

func _ready():
	agent.path_desired_distance = 4.0
	agent.target_desired_distance = 4.0
	
	call_deferred("actor_setup")
	
func actor_setup():	
	await get_tree().physics_frame
	set_movement_target(target.position)
	
func set_movement_target(target: Vector2):
	agent.target_position = target
	
	
func _physics_process(delta):
	if agent.is_navigation_finished():
		return
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
	if velocity.y < -1.5: current_direction = "up"
	elif velocity.y > 1.5: current_direction = "down"
	elif velocity.x < -1.5: current_direction = "left"
	elif velocity.x > 1.5: current_direction = "right"
	
	if current_direction != direction:
		direction = current_direction
		direction_change.emit(direction)
