extends Node2D

@onready var areaR = $ColorRectR/Area2D
@onready var areaL = $ColorRectL/Area2D

var allow_left_transition = true
var allow_right_transition = true

func _on_right_area_2d_body_entered(body):
	if body.velocity.x > 0:
		body.position.x = areaL.global_position.x + 24
		allow_left_transition = false
func _on_left_area_2d_body_entered(body):
	if body.velocity.x < 0:
		body.position.x = areaR.global_position.x + 24
		allow_right_transition = false

func _on_right_area_2d_body_exited(body):
	allow_right_transition = true
func _on_left_area_2d_body_exited(body):
	allow_left_transition = true
