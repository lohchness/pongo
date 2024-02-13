extends StaticBody2D

var curr_speed
var normal_speed = 500
@export var player_number: int = 0 # set this in editor

var paddle_length : int
var is_moving : bool = false
var original_position : Vector2

var window
const DISTANCE_FROM_EDGE = 20

# Buffs
# Size Up
var base_scale : Vector2
var size_up_multiplier = 1
var size_up_secs = 5
var is_sized_up = false
@onready var size_up_timer = $Timers/SizeUp
# Movement speed Up
var paddle_speed_mult = 1.5
var is_paddle_sped_up = false
var speed_up_secs = 5
@onready var speed_up_timer = $Timers/SpeedUp


# CPU variables
var ball_pos : Vector2
var dist : int
var move_by : int
var win_height : int

# Called when the node enters the scene tree for the first time.
func _ready():
	paddle_length = $Sprite2D.texture.get_height()
	window = get_viewport_rect().size
	win_height = window.y
	
	if (player_number == 1):
		original_position = Vector2(DISTANCE_FROM_EDGE, window.y / 2)
	else:
		original_position = Vector2(window.x - DISTANCE_FROM_EDGE, window.y / 2)
	
	base_scale = $Sprite2D.scale
	size_up_timer.wait_time = size_up_secs
	
	curr_speed = normal_speed
	speed_up_timer.wait_time = speed_up_secs
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var new_scale = Vector2(base_scale.x, base_scale.y * size_up_multiplier)
	$Sprite2D.scale = new_scale
	$CollisionShape2D.scale = new_scale
	paddle_length = $Sprite2D.texture.get_height()
	
	
	is_moving = false
	
	var movement = curr_speed * delta
	
	if player_number == 1:
		if Input.is_key_pressed(KEY_W):
			moveUp(movement)
		if Input.is_key_pressed(KEY_S):
			moveDown(movement)
	elif player_number == 2:
		if Input.is_action_pressed("ui_up"):
			moveUp(movement)
		if Input.is_action_pressed("ui_down"):
			moveDown(movement)
	# CPU
	elif player_number == 3:
		# move paddle to ball
		ball_pos = $"../../../Ball/ball".position
		dist = position.y - ball_pos.y
		
		var dist_to = position.distance_to(ball_pos)
		#
		#if abs(dist_to) < 100:
			#move_and_collide(Vector2.DOWN * -move_by)
			#
		#else:
		
		var curr_move_by
		
		if abs(dist) > curr_speed * delta:
			curr_move_by = curr_speed * delta * (dist / abs(dist))
		else:
			curr_move_by = dist
		
		move_by = curr_move_by
		
		move_and_collide(Vector2.DOWN * -curr_move_by)
		

func moveUp(movement):
	is_moving = true
	move_and_collide(Vector2.UP * movement)

func moveDown(movement):
	is_moving = true
	move_and_collide(Vector2.DOWN * movement)

func reset_paddle():
	position = original_position
	size_up_multiplier = 1
	curr_speed = normal_speed

func size_up():
	if is_sized_up:
		return
	size_up_multiplier = 2
	is_sized_up = true
	
	if position.y < win_height / 2:
		position.y += paddle_length / 2
	else:
		position.y -= paddle_length /2
	
	size_up_timer.start()
	
func _on_size_up_timeout():
	size_up_multiplier = 1
	is_sized_up = false

func speed_up():
	if is_paddle_sped_up:
		return
	curr_speed = normal_speed * paddle_speed_mult
	is_paddle_sped_up = true
	speed_up_timer.start()

func _on_speed_up_timeout():
	curr_speed = normal_speed
	is_paddle_sped_up = false
