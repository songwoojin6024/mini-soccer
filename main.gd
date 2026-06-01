extends Node2D

@onready var score_label = $CanvasLayer/ScoreLabel
@onready var timer_label = $CanvasLayer/TimerLabel
@onready var ball_sound_player = $BallSoundPlayer
@onready var stadium_sound_player = $StadiumSoundPlayer
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var resume_button = $CanvasLayer/PauseMenu/ResumeButton
@onready var pause_main_menu_button = $CanvasLayer/PauseMenu/MainMenuButton
@export var ball_scene: PackedScene

var player_start_pos = Vector2.ZERO
var ball_start_pos = Vector2.ZERO
var ai_start_pos = Vector2.ZERO
var left_score = 0
var right_score = 0
var game_time = 0
var is_halftime = false
var is_game_over = false
var is_extra_time = false
var wind_force = 0.0
var wind_label = null
var environment_overlay = null
var first_half_event_started = false
var second_half_event_started = false
var original_player_speed = 300
var original_ai_speed = 330
var is_paused_menu_open = false

@onready var ball = $Ball
@onready var left_goal = $LeftGoalPost
@onready var right_goal = $RightGoalPost
@onready var timer = $Timer

func _ready():
	player_start_pos = $Player.global_position
	ball_start_pos = ball.position
	left_goal.body_entered.connect(_on_left_goal_entered)
	right_goal.body_entered.connect(_on_right_goal_entered)
	ai_start_pos = $Player2.position

	pause_menu.visible = false
	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	resume_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_main_menu_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	resume_button.pressed.connect(hide_pause_menu)
	pause_main_menu_button.pressed.connect(_on_pause_main_menu_pressed)
	
	stadium_sound_player.play()
	start_countdown()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		show_pause_menu()
		get_viewport().set_input_as_handled()
		
		
func _physics_process(delta):
	if wind_force != 0.0 and ball != null:
		ball.apply_central_force(Vector2(wind_force, 0))


func reset_positions():
	ball.queue_free()
	await get_tree().process_frame
	# 새 볼 생성
	ball = ball_scene.instantiate()
	add_child(ball)
	ball.global_position = ball_start_pos
	# 플레이어 리셋
	$Player.position = player_start_pos
	$Player.velocity = Vector2.ZERO
	# AI 리셋
	$Player2.position = ai_start_pos

	
func _on_left_goal_entered(body):
	if body.name == "Ball":
		right_score += 1
		update_hud()
		reset_positions()

func _on_right_goal_entered(body):
	if body.name == "Ball":
		left_score += 1
		update_hud()
		reset_positions()

func update_hud():
	score_label.text = str(left_score) + " : " + str(right_score)
	
func play_ball_sound():
	if ball_sound_player.playing:
		ball_sound_player.stop()
	ball_sound_player.play()
	
func _on_timer_timeout() -> void:
	game_time += 1
	timer_label.text = str(game_time)

	if game_time == 45 and not is_halftime:
		is_halftime = true
		$Timer.stop()
		show_halftime()

	elif game_time >= 90 and not is_extra_time:
		if left_score == right_score:
			start_extra_time()
		else:
			$Timer.stop()
			game_over()

	elif is_extra_time and game_time >= 120:
		$Timer.stop()
		game_over()
		
func show_halftime():
	$CanvasLayer/TimerLabel.text = "HALF TIME"
	$Player.set_physics_process(false)
	$Player2.set_physics_process(false)
	reset_positions()
	await get_tree().create_timer(3.0).timeout
	$Player.set_physics_process(true)
	$Player2.set_physics_process(true)
	game_time = 45
	$Timer.start()
	start_random_environment_event()
	
func game_over():
	is_game_over = true
	$Timer.stop()
	$Player.set_physics_process(false)
	$Player2.set_physics_process(false)
	
	# 기존 라벨 숨기기
	$CanvasLayer/ScoreLabel.visible = false
	$CanvasLayer/TimerLabel.visible = false
	
	# 승패 판정
	var player_won = left_score > right_score

	if left_score == right_score:
		player_won = randi() % 2 == 0
	
	# GameManager에 결과 저장
	GameManager.player_score = left_score
	GameManager.ai_score = right_score
	GameManager.set_match_result(player_won)
	
	# 결과 라벨 새로 만들기
	var result_label = Label.new()
	$CanvasLayer.add_child(result_label)
	
	if player_won:
		result_label.text = "FULLTIME\n플레이어 승리!\n" + str(left_score) + " : " + str(right_score)
	else:
		result_label.text = "FULLTIME\nAI 승리!\n" + str(left_score) + " : " + str(right_score)
	
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.position = Vector2(0, 100)
	result_label.size = Vector2(1152, 300)
	result_label.add_theme_font_size_override("font_size", 48)
	
	# 3초 후 토너먼트로 복귀
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://tournament.tscn")
func start_extra_time():
	is_extra_time = true
	$Timer.stop()

	$Player.set_physics_process(false)
	$Player2.set_physics_process(false)
	reset_positions()

	var extra_label = Label.new()
	$CanvasLayer.add_child(extra_label)
	extra_label.text = "무승부!\n연장전 30초 시작"
	extra_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	extra_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	extra_label.position = Vector2(0, 160)
	extra_label.size = Vector2(1152, 220)
	extra_label.add_theme_font_size_override("font_size", 48)

	await get_tree().create_timer(3.0).timeout

	extra_label.queue_free()
	$Player.set_physics_process(true)
	$Player2.set_physics_process(true)
	$Timer.start()
func start_countdown():
	$Player.set_physics_process(false)
	$Player2.set_physics_process(false)
	ball.freeze = true
	$Timer.stop()

	var countdown_label = Label.new()
	$CanvasLayer.add_child(countdown_label)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.position = Vector2(0, 180)
	countdown_label.size = Vector2(1152, 200)
	countdown_label.add_theme_font_size_override("font_size", 96)

	countdown_label.text = "3"
	await get_tree().create_timer(1.0).timeout

	countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout

	countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout

	countdown_label.text = "START!"
	await get_tree().create_timer(0.5).timeout

	countdown_label.queue_free()
	ball.freeze = false
	$Player.set_physics_process(true)
	$Player2.set_physics_process(true)
	$Timer.start()
	start_random_environment_event()

func toggle_pause_menu():
	if is_game_over:
		return

	if is_paused_menu_open:
		hide_pause_menu()
	else:
		show_pause_menu()

func show_pause_menu():
	is_paused_menu_open = true
	pause_menu.visible = true
	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_tree().paused = true

func hide_pause_menu():
	is_paused_menu_open = false
	pause_menu.visible = false
	get_tree().paused = false

func _on_pause_main_menu_pressed():
	get_tree().paused = false
	GameManager.reset()
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func start_random_environment_event():
	if game_time < 45:
		if first_half_event_started:
			return
		first_half_event_started = true
	else:
		if second_half_event_started:
			return
		second_half_event_started = true

	var wait_time = randf_range(5.0, 25.0)
	await get_tree().create_timer(wait_time, false, false).timeout

	if is_game_over:
		return

	var event_type = randi() % 4

	if event_type == 0:
		start_wind_event()
	elif event_type == 1:
		start_night_event()
	elif event_type == 2:
		start_heat_event()
	else:
		start_snow_event()
		
func start_wind_event():
	var direction = 1
	if randi() % 2 == 0:
		direction = -1

	var strength = randf_range(300.0, 550.0)
	wind_force = direction * strength

	wind_label = Label.new()
	$CanvasLayer.add_child(wind_label)

	if direction > 0:
		wind_label.text = "바람: 오른쪽 →"
	else:
		wind_label.text = "바람: 왼쪽 ←"

	wind_label.position = Vector2(20, 20)
	wind_label.size = Vector2(400, 60)
	wind_label.add_theme_font_size_override("font_size", 32)
	wind_label.add_theme_color_override("font_color", Color.SKY_BLUE)

	await get_tree().create_timer(10.0, false, false).timeout
	wind_force = 0.0
	if wind_label != null:
		wind_label.queue_free()
		wind_label = null
		
func start_night_event():
	environment_overlay = ColorRect.new()
	$CanvasLayer.add_child(environment_overlay)

	environment_overlay.color = Color(0, 0, 0, 0.60)
	environment_overlay.position = Vector2(0, 0)
	environment_overlay.size = Vector2(1152, 648)
	environment_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var label = Label.new()
	$CanvasLayer.add_child(label)
	label.text = "야간 경기"
	label.position = Vector2(20, 20)
	label.size = Vector2(300, 60)
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color.WHITE)

	await get_tree().create_timer(10.0, false, false).timeout

	if environment_overlay != null:
		environment_overlay.queue_free()
		environment_overlay = null
	label.queue_free()
	
func start_heat_event():
	original_player_speed = $Player.speed
	original_ai_speed = $Player2.speed

	$Player.speed *= 0.65
	$Player2.speed *= 0.65

	var label = Label.new()
	$CanvasLayer.add_child(label)
	label.text = "폭염주의\n이동 속도 감소"
	label.position = Vector2(20, 20)
	label.size = Vector2(400, 90)
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color.ORANGE_RED)

	await get_tree().create_timer(10.0, false, false).timeout

	$Player.speed = original_player_speed
	$Player2.speed = original_ai_speed

	label.queue_free()
func start_snow_event():
	var original_player_jump = $Player.jump_force
	var original_ai_jump = $Player2.jump_force

	$Player.jump_force *= 0.6
	$Player2.jump_force *= 0.6

	var label = Label.new()
	$CanvasLayer.add_child(label)
	label.text = "한파주의\n점프력 감소 / 공 둔화"
	label.position = Vector2(20, 20)
	label.size = Vector2(500, 90)
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color.WHITE)

	var snow_overlay = ColorRect.new()
	$CanvasLayer.add_child(snow_overlay)
	snow_overlay.color = Color(1, 1, 1, 0.2)
	snow_overlay.position = Vector2(0, 0)
	snow_overlay.size = Vector2(1152, 648)
	snow_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var elapsed = 0.0
	while elapsed < 10.0:
		if ball != null:
			ball.linear_velocity *= 0.94

		await get_tree().create_timer(0.2, false, false).timeout
		elapsed += 0.2

	$Player.jump_force = original_player_jump
	$Player2.jump_force = original_ai_jump

	snow_overlay.queue_free()
	label.queue_free()
