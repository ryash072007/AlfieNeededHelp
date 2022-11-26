extends KinematicBody2D
class_name Player

signal grounded_update(is_grounded)
signal health_updated(health) ###########
signal killed() ###########

const UP = Vector2(0, -1)
const DROP_THRU_BIT = 1
const SLOPE_STOP_THRESHOLD = 64.0

export (float) var max_health = 100 ###########
onready var healthBarNode = get_node("%HealthBar") ###########
onready var health = max_health setget _set_health ###########

var velocity = Vector2()
var move_speed = 5 * Globals.UNIT_SIZE
var gravity
var max_jump_velocity
var min_jump_velocity  
var is_grounded
var is_jumping = false
var move_direction

var max_jump_height = 2.1 * Globals.UNIT_SIZE
var min_jump_height = 0.7 * Globals.UNIT_SIZE
var jump_duration = 0.5

onready var raycasts = $Body/Raycasts
onready var anim_player = $Body/Sprite/AnimationPlayer
onready var body_collision = $CollisionPolygon2D

onready var invulnerability_timer = $InvulnerabilityTimer
onready var effects_animation = $EffectsAnimation ###########

func _ready():
	connect("health_updated", healthBarNode, "_on_health_bar_updated") ###########
	gravity = 3.5 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #HidesMousePointer

func _physics_process(_delta): #ESC to close game
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _apply_gravity(delta):
	velocity.y += gravity * delta

func _apply_movement():
	if is_jumping && velocity.y >= 0:
		is_jumping = false
	
	var snap = Vector2.DOWN * 32 if !is_jumping else Vector2.ZERO
	
	if move_direction == 0 && abs(velocity.x) < SLOPE_STOP_THRESHOLD:
		velocity.x = 0
	
	var stop_on_slope = true if get_floor_velocity().x == 0 else false

	velocity = move_and_slide_with_snap(velocity, snap, UP, stop_on_slope)
	
	var was_grounded = is_grounded
	is_grounded = is_on_floor()
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_update", is_grounded)

	is_grounded = !is_jumping && get_collision_mask_bit(DROP_THRU_BIT) && _check_is_grounded()

func _handle_move_input():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction !=0:
		$Body.scale.x = move_direction

#0.05 is bit too low
func _get_h_weight():
	return 0.2 if is_grounded else 0.1

func _check_is_grounded(raycasts = self.raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	
	#if loop completes then raycast was not detected
	return false

func _on_Area2D_body_exited(_body):
	set_collision_mask_bit(DROP_THRU_BIT, true)
	body_collision.call_deferred("set_disabled", false)

func damage(amount): ###########
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health - amount)
		effects_animation.play("damage")
		effects_animation.queue("flash")
		
func kill(): ###########
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().reload_current_scene()

func _set_health(value): ###########
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health) ####added"_on_health_bar_updated"#####
		if health == 0:
			kill()
			emit_signal("killed")

func _on_InvulnerabilityTimer_timeout(): ###########
	effects_animation.play("rest")
