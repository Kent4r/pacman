extends Node

class_name PointsManager

var points_for_ghost_eaten = 200
var score = 0

func pause_on_ghost_eaten():
	score += points_for_ghost_eaten
	points_for_ghost_eaten *= 2
	
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false

func reset_points_for_ghost():
	points_for_ghost_eaten = 200
