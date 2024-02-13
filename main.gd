extends Node2D

var p1_pts = 0
var p2_pts = 0

var window

@onready var p1_paddle = $Paddles/P1_paddle/Player1
@onready var p2_paddle = $Paddles/P2_paddle/Player2
@onready var ball = $Ball/ball

@onready var timer = $UI/RoundStartTimer
@onready var countdownLabel = $UI/RoundStartCountdown
@onready var ui_p1_score = $UI/Player1_Score
@onready var ui_p2_score = $UI/Player2_Score

@export var size_ups : PackedScene
@onready var sizeuptimer = $BuffTimers/SizeUpTimer
@export var speed_ups : PackedScene
@onready var speeduptimer = $BuffTimers/SpeedUpTimer

var count = 4;
var countdown = count

const MAXPOINTS : int = 3
@onready var winnerlabel = $UI/Winner
@onready var restarttimer = $UI/RestartTimer
@onready var restartlabel = $UI/Restart

const ROUNDSTART : int = 0
const PLAYING : int = 1
const GAMEOVER : int = 2
var gamestate : int = 0

func _ready():
	window = get_viewport_rect().size
	speeduptimer.wait_time = randi_range(5, 15)
	sizeuptimer.wait_time = randi_range(5, 15)
	reset_game_state()
	
	if Variables.is_two_players:
		$Paddles/P2_paddle/Player2.player_number = 2
	else:
		$Paddles/P2_paddle/Player2.player_number = 3		

func _process(delta):
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
		
	match gamestate:
		ROUNDSTART:
			sizeuptimer.stop()
			speeduptimer.stop()
			
			countdownLabel.visible = true
			
			if (p1_pts == MAXPOINTS):
				winnerlabel.text = "Player one wins!"
				game_over()
			elif (p2_pts == MAXPOINTS):
				winnerlabel.text = "Player two wins!"
				game_over()
				
			if (countdown > 1):
				countdownLabel.text = str(countdown - 1)
			elif (countdown == 1):
				countdownLabel.text = "PONGO!"
			else:
				if (sizeuptimer.is_stopped()):
					sizeuptimer.start()
					speeduptimer.start()
				countdownLabel.visible = false
				
				gamestate = PLAYING
				start_new_game()
				
		PLAYING:
			pass
			
		GAMEOVER:
			if (Input.is_key_pressed(KEY_SPACE)):
				reset_entire_game()

func _on_p1_score():
	p1_pts += 1
	ui_p1_score.text = str(p1_pts)
	reset_game_state()

func _on_p2_score():
	p2_pts += 1
	ui_p2_score.text = str(p2_pts)
	reset_game_state()
	
func game_over():
	pause_game()
	ball.visible = false
	gamestate = GAMEOVER
	countdownLabel.visible = false
	winnerlabel.visible = true
	restartlabel.visible = true
	restarttimer.start()
	

func reset_entire_game():
	p1_pts = 0
	p2_pts = 0
	ui_p1_score.text = str(p1_pts)
	ui_p2_score.text = str(p2_pts)
	
	countdownLabel.visible = true
	winnerlabel.visible = false
	restartlabel.visible = false
	restarttimer.stop()
	reset_game_state()
	
func reset_game_state():
	gamestate = ROUNDSTART
	get_tree().call_group("buffs", "queue_free")
	
	p1_paddle.reset_paddle()
	p2_paddle.reset_paddle()
	ball.reset_ball_position()
	ball.visible = true
	
	countdown = count
	
func start_new_game():
	ball.start_ball()
	resume_timers()

func _on_timer_timeout():
	countdown -= 1
	
func buff_new_position():
	var new_x = randf_range(window.x / 10, 9 * window.x / 10)
	var new_y = randf_range(window.y / 5, 4 * window.y / 5)
	var new_position = Vector2(new_x, new_y)
	
	return new_position

func pause_game():
	p1_paddle.reset_paddle()
	p2_paddle.reset_paddle()
	ball.reset_ball_position()
	pause_timers()

func pause_timers():
	speeduptimer.paused = true
	sizeuptimer.paused = true
	
func resume_timers():
	speeduptimer.paused = false
	sizeuptimer.paused = false

func _on_size_up_timer_timeout():
	# Two in three chances of not happening
	if (randi() % 3 == 1): return
	# Create new instance of Size Up
	var size_up = size_ups.instantiate()
	# Connect its body_entered signal with ball's function
	size_up.connect("body_entered", ball._on_size_up_body_entered)
	size_up.position = buff_new_position()
	# Add to scene
	add_child(size_up)
	# New random timer interval
	sizeuptimer.wait_time = randi_range(5, 15)

func _on_speed_up_timer_timeout():
	# One in two chances of not happening
	if (randi() % 2 == 1): return
	var speed_up = speed_ups.instantiate()
	speed_up.connect("body_entered", ball._on_speed_up_body_entered)
	speed_up.position = buff_new_position()
	add_child(speed_up)
	speeduptimer.wait_time = randi_range(5, 15)

func _on_restart_timer_timeout():
	restartlabel.visible = !restartlabel.visible
