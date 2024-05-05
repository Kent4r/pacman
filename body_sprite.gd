extends Sprite2D

@onready var blinky = $".."

func _ready():
	self.modulate = blinky.color
