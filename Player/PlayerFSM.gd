extends "res://Player/StateMachine.gd"

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", states.idle)

func _input(event):
	if [states.idle, states.run].has(state):
		#JUMP
		if event.is_action_pressed("jump") && parent.is_grounded:
				parent.velocity.y = parent.max_jump_velocity
				parent.is_jumping = true
				
		#DROP THROUGH PLATFORM
		if Input.is_action_pressed("down") && parent.is_grounded:
				if parent._check_is_grounded(get_parent().get_node("Body/DropThruRaycasts")):
					parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)
					parent.body_collision.call_deferred("set_disabled", true)

	if state == states.jump:
		#VARIABLE JUMP
		if event.is_action_released("jump") && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity

func _state_logic(delta):
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()

func _get_transition(_delta):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
	
	return null

func _enter_state(_new_state, _old_state):
	match _new_state:
		states.idle:
			parent.anim_player.play("idle")
		states.run:
			parent.anim_player.play("run")
		states.jump:
			parent.anim_player.play("jump")
		states.fall:
			parent.anim_player.play("fall")

func _exit_state(_old_state, _new_state):
	pass
