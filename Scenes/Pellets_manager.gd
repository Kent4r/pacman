extends Node2D

var total_pellets_count
var pellets_eaten = 0

@export var ghosts: Array[CharacterBody2D]

@onready var ui = $"../UI" as UI
@onready var points_manager = $"../PointsManager"
@onready var chomp_sp = $"../SoundPlayers/ChompSP"
@onready var power_pellet_sp = $"../SoundPlayers/PowerPelletSP"

func _ready():
	var pellets = self.get_children() as Array[Pellet]
	total_pellets_count = pellets.size()
	for pellet in pellets:
		pellet.pellet_eaten.connect(on_pellet_eaten)

func restart_pellets():
	var pellets = self.get_children() as Array[Pellet]
	for pellet in pellets:
		pellet.restart()
	_ready()
	pellets_eaten = 0

func _physics_process(delta):
	if !(ghosts[0].IS_SCARED() or ghosts[1].IS_SCARED() or ghosts[2].IS_SCARED() or ghosts[3].IS_SCARED()):power_pellet_sp.stop()

func on_pellet_eaten(should_allow_eating_ghosts: bool):
	if !chomp_sp.playing:
		chomp_sp.play()
	pellets_eaten += 1
	
	if should_allow_eating_ghosts:
		ui.update_score(100)
		power_pellet_sp.play()
		get_tree().create_timer(10).timeout.connect(reset_points_for_ghost)
		for ghost in ghosts:
			ghost.run_away()
	else: ui.update_score(10)
	
	if pellets_eaten == total_pellets_count:
		ui.game_won()

func reset_points_for_ghost():
	points_manager.reset_points_for_ghost()
