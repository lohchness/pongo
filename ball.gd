extends CharacterBody2D

const BASE_VELOCITY = 300
var speed_mult = 1.02
var curr_speed = BASE_VELOCITY
var direction = velocity
const MAX_SPEED_MULTIPLIER = 2
var paddle_speed_up_mult = 1.5

var CEILING_SPEED = 650

# Decelerate
var normal_speed = curr_speed
var max_speed: float
var is_fast = false

var last_object_hit : Object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#start_ball()
	pass
	
func reset_ball_position():
	position = Vector2(300, 300)
	direction = Vector2.ZERO	
	
func start_ball():
	curr_speed = BASE_VELOCITY
	normal_speed = curr_speed
	max_speed = curr_speed * MAX_SPEED_MULTIPLIER
	position = Vector2(300, 300)
	
	randomize()
	direction.x = [-1,1][randi() % 2 ]
	direction.y = randf_range(-.5, .5)
	direction = direction.normalized()
	is_fast = false

func _physics_process(delta):
	
	var collision = move_and_collide(direction * curr_speed * delta)
	
	if is_fast:
		curr_speed /= 1.01 # Decelerate after hitting a moving paddle
	
	if curr_speed < normal_speed:
		curr_speed = normal_speed
		is_fast = false
	
	if collision:
		var collider = collision.get_collider()
		
		
		if collider in [$"../../Paddles/P1_paddle/Player1", $"../../Paddles/P2_paddle/Player2"]:
			
			if normal_speed < CEILING_SPEED:
				curr_speed = curr_speed * speed_mult
				normal_speed = normal_speed * speed_mult
			
			last_object_hit = collider
			
			direction = new_direction(collider)
			
			# if paddle is moving, then make ball move fast and decelerate
			if collider.is_moving:
				curr_speed = max_speed
				if collider.is_paddle_sped_up:
					curr_speed = max_speed * paddle_speed_up_mult
				is_fast = true
			else: # If not moving, go back to normal speed
				curr_speed = normal_speed
			
		else:  # hit a wall
			direction = direction.bounce(collision.get_normal())
	
	max_speed = normal_speed * MAX_SPEED_MULTIPLIER
	
	
func new_direction(collider):
	var ball_y = position.y
	var paddle_y = collider.position.y
	var dist = ball_y - paddle_y
	var new_dir := Vector2()
	
	# flip x / horizontal direction
	if direction.x > 0: # moving to right
		new_dir.x = -1
	else:
		new_dir.x = 1
	new_dir.y = (dist / (collider.paddle_length / 2)) # * MAX_Y_VECTOR
	# how far from ball center from paddle center divided by height of paddle
	return new_dir.normalized()

func _on_size_up_body_entered(body):
	if last_object_hit == null:
		return
	last_object_hit.size_up()


func _on_speed_up_body_entered(body):
	if last_object_hit == null:
		return
	last_object_hit.speed_up()
