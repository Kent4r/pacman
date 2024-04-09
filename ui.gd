extends CanvasLayer

class_name UI

@onready var center_container = $MarginContainer/CenterContainer
@onready var camera_2d = $"../Camera2D"
@onready var tile_map = $"../TileMap"
@onready var pellets = $"../Pellets"
@onready var connector = $"../Connector"
@onready var connector_2 = $"../Connector2"
@onready var pacman = $"../pacman"

func game_won():
	center_container.show()
	camera_2d.hide()
	connector_2.hide()
	connector.hide()
	pellets.hide()
	tile_map.hide()
	pacman.hide()
