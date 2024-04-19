extends Node2D



func _on_menu_button_exit_pressed():
	get_tree().quit()


func _on_menu_button_new_game_pressed():
	get_tree().change_scene_to_file("res://GameKingom/GameLevel/game_kingdom.tscn")
	
