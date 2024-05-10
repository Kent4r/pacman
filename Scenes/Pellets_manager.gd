extends Node2D

var total_pellets_count
var pellets_eaten = 0

@onready var ui = $"../UI" as UI
@onready var blinky = $"../Ghosts/red/Blinky"
@onready var pinky = $"../Ghosts/pink/Pinky"
@onready var inky = $"../Ghosts/cyan/Inky"
@onready var clyde = $"../Ghosts/orange/Clyde"

func _ready():
	var pellets = self.get_children() as Array[Pellet]
	total_pellets_count = pellets.size()
	for pellet in pellets:
		pellet.pellet_eaten.connect(on_pellet_eaten)
		
		
func on_pellet_eaten(should_allow_eating_ghosts: bool):
	pellets_eaten += 1
	
	if should_allow_eating_ghosts:
		blinky.run_away()
		pinky.run_away()
		inky.run_away()
		clyde.run_away()
	
	if pellets_eaten == total_pellets_count:
		ui.game_won()
