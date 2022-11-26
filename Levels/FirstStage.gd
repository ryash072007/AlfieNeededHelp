extends Node2D

func _physics_process(_delta): #ESC to close game
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
 
