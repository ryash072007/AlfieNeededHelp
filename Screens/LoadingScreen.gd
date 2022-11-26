extends Control

func _ready():
	randomize()
	var t = rand_range(2,5)
	yield(get_tree().create_timer(t),"timeout")
	Transitions.play_exit_transition()#aniamtioncalledtransitions
	get_tree().paused = true
	yield(Transitions, "transition_completed")
	Transitions.play_enter_transition()
	get_tree().paused = false
	get_tree().change_scene("res://Title/HouseIntro.tscn")
