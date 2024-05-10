extends Sprite2D

@onready var animation_player = $"../AnimationPlayer"
@onready var ghost = $".."

func _ready():
	move()

func move():
	self.modulate = ghost.color
	animation_player.play("moving")

func run_away():
	self.modulate = Color.WHITE
	animation_player.play("running_away")

func recover_from_run_away():
	self.modulate = Color.WHITE
	animation_player.play("recover_from_run_away")
