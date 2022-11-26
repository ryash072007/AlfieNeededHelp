extends Area2D

func _on_Spike_body_entered(body):
	if body is Player:
		body.damage(19)
