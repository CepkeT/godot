extends Node

@onready var pause_menu = $"../Statuses/PauseMenu"

var game_paused: bool = false
		
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		game_paused = !game_paused
		
	if game_paused == true:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()


func _on_resume_pressed():
	game_paused = !game_paused


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://GameKingom/Menu/menu_kingdom.tscn")


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://GameKingom/GameLevel/game_kingdom.tscn")
