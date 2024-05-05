extends Sprite2D

@onready var animation_player = $"../AnimationPlayer"
@onready var ghost = $".."

func _ready():
	self.modulate = ghost.color
	animation_player.play("moving")
