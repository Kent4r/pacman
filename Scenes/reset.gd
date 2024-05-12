extends Control

@onready var player = $"../../../../../pacman" as Player

func _physics_process(delta):
	get_input()

func get_input():
	if Input.is_action_pressed("Restart"):
		#player.restart_game()
		pass
