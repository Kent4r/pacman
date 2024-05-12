extends Control

func _process(delta):
	get_input()

func get_input():
	if Input.is_action_pressed("Restart"):
		print("reset")
