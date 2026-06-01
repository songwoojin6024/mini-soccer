extends CharacterBody2D

@export var speed = 330
@export var jump_force = -620

var gravity = 980
var shoot_power = 1450
var shoot_cooldown = 0.0

var right_goal_x = 980
var left_goal_x = 140
var defend_x = 820

@onready var anim = $AnimatedSprite2D

func _ready():
	var opponent_team = GameManager.get_current_opponent_team()
	var frames = load(GameManager.get_character_frames(opponent_team))
	if frames != null:
		anim.sprite_frames = frames
		anim.play("idle")

	var character_scale = GameManager.get_character_scale(opponent_team)
	anim.scale = Vector2(character_scale, character_scale)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	shoot_cooldown -= delta

	var ball = get_node("/root/Main/Ball")
	var target_x = choose_target_x(ball)

	move_to_target(target_x)
	try_jump(ball)
	try_shoot(ball)

	if not is_on_floor():
		anim.play("jump")

	move_and_slide()
func choose_target_x(ball):
	# 공이 AI 골대 근처면 수비
	if ball.global_position.x > 720:
		return ball.global_position.x

	# 공이 중앙이면 공과 골대 사이를 지킴
	if ball.global_position.x > 420:
		return ball.global_position.x + 70

	# 공이 너무 왼쪽이면 무작정 따라가지 않고 수비 위치 유지
	return defend_x

func move_to_target(target_x):
	if target_x < global_position.x - 15:
		velocity.x = -speed
		if is_on_floor():
			anim.play("run")
		anim.flip_h = true
	elif target_x > global_position.x + 15:
		velocity.x = speed
		if is_on_floor():
			anim.play("run")
		anim.flip_h = false
	else:
		velocity.x = 0
		if is_on_floor():
			anim.play("idle")

func try_jump(ball):
	if not is_on_floor():
		return

	var ball_is_high = ball.global_position.y < global_position.y - 45
	var ball_is_close_x = abs(ball.global_position.x - global_position.x) < 130

	if ball_is_high and ball_is_close_x:
		velocity.y = jump_force
		anim.play("jump")

func try_shoot(ball):
	if shoot_cooldown > 0:
		return

	var distance = global_position.distance_to(ball.global_position)

	if distance < 115:
		shoot(ball)
		shoot_cooldown = 1.0

func shoot(ball):
	anim.play("shoot")

	var direction = Vector2(-1, -0.35)

	# 공이 높으면 헤딩/로빙 느낌으로 더 위로 참
	if ball.global_position.y < global_position.y - 20:
		direction.y = -0.8

	# AI 골대 근처에서는 강하게 걷어내기
	if global_position.x > 780:
		direction = Vector2(-1, -0.55)

	ball.apply_central_impulse(direction.normalized() * shoot_power)
	get_node("/root/Main").play_ball_sound()
