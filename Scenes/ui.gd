extends CanvasLayer

class_name UI

var score = 0
var lifes = 3
var Can_Restart: bool = false
var game_was_lost: bool = false

@export var ghosts: Array[CharacterBody2D]

@onready var center_container = $MarginContainer/CenterContainer
@onready var camera_2d = $"../Camera2D"
@onready var tile_map = $"../TileMap"
@onready var pellets = $"../Pellets"
@onready var connector = $"../Connector"
@onready var connector_2 = $"../Connector2"
@onready var pacman = $"../pacman"
@onready var lifes_table = %Lifes
@onready var game_score = %GameScore
@onready var game_label = %GameLabel
@onready var restart = $MarginContainer/CenterContainer/Panel/Restart

func _physics_process(delta):
	set_lifes(lifes)
	set_score(score)
	get_input()

func get_input():
	if Can_Restart and Input.is_action_pressed("Restart"):
		if game_was_lost: get_tree().reload_current_scene()
		else:
			show_all()
			Can_Restart = false
			center_container.hide()
			pacman.restart_game()

func update_score(new_score):
	score += new_score

func update_lifes(new_life):
	lifes += new_life

func set_lifes(lifes):
	lifes_table.text = "%d UP" % lifes

func set_score(score):
	game_score.text = "SCORE: %d" % score

func game_lost():
	game_was_lost = true
	Can_Restart = true
	lifes-=1
	center_container.show()
	hide_all()
	game_label.text = "YOU LOST! :("

func show_all():
	camera_2d.show()
	connector_2.show()
	connector.show()
	pellets.show()
	tile_map.show()
	pacman.show()

func hide_all():
	camera_2d.hide()
	connector_2.hide()
	connector.hide()
	pellets.hide()
	tile_map.hide()
	pacman.hide()
	for ghost in ghosts:
		ghost.hide_from_UI()

func game_won():
	Can_Restart = true
	center_container.show()
	restart.text = "CONTINUE?"
	hide_all()
	game_label.text = "YOU WON! :)"
