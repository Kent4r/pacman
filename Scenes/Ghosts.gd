extends Node

@onready var player = $"../pacman" as Player
@onready var blinky = $red/Blinky
@onready var pinky = $pink/Pinky
@onready var inky = $cyan/Inky
@onready var clyde = $orange/Clyde


func _ready():
	player.player_died.connect(reset_ghosts)

func reset_ghosts():
	blinky._ready()
	pinky._ready()
	inky._ready()
	clyde._ready()
