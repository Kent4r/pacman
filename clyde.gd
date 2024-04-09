extends CharacterBody2D

@export var speed = 150
@export var target: Node2D
@export var agent: NavigationAgent2D

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
	
	velocity = new_velocity
	move_and_slide()
