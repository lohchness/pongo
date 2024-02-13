extends Node2D

func _process(delta):
	if Input.is_key_pressed(KEY_1):
		_on_oneplayer_pressed()
	if Input.is_key_pressed(KEY_2):
		_on_twoplayer_pressed()

func _on_oneplayer_pressed():
	Variables.is_two_players = false
	get_tree().change_scene_to_file("res://main.tscn")

func _on_twoplayer_pressed():
	Variables.is_two_players = true
	get_tree().change_scene_to_file("res://main.tscn")
