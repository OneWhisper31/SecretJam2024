extends Node3D

var isRetrying :bool

func _retry():
	if !isRetrying:
		isRetrying=true
		get_tree().change_scene_to_file("res://Scenes/level.tscn")

#func _menu():
#	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
