extends Sprite2D

@export_group("Eye Textures")
@export var up: Texture2D
@export var down: Texture2D
@export var left: Texture2D
@export var right: Texture2D
@export_group("")
@onready var ghost = $".."
@onready var direction_lookup_table = { "up": up, "down": down, "left": left, "right": right }

func _ready():
	ghost.direction_change.connect(on_direction_change)
	
func on_direction_change(direction: String):
	texture = direction_lookup_table[direction]
