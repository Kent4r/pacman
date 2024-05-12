extends Area2D

class_name Pellet

signal pellet_eaten(should_allow_eating_ghosts: bool)

@export var should_allow_eating_ghosts = false

var visibility: bool = true

func _on_body_entered(body):
	if body is Player:
		if visibility:
			pellet_eaten.emit(should_allow_eating_ghosts)
			self.hide()
			visibility = false

func restart():
	self.show()
	visibility = true
