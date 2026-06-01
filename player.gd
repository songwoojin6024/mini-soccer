extends CharacterBody2D

@export var speed = 300
@export var jump_force = -600
var gravity = 980
var shoot_power = 0
var is_charging = false
var max_power = 2500

@onready var anim = $AnimatedSprite2D
@onready var power_bar = $PowerBar

func _ready():
	var frames = load(GameManager.get_character_frames("YOU"))
	if frames != null:
		anim.sprite_frames = frames
		anim.play("idle")

	var character_scale = GameManager.get_character_scale("YOU")
	anim.scale = Vector2(character_scale, character_scale)

	power_bar.visible = false
	power_bar.min_value = 0
	power_bar.max_value = max_power

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		anim.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		anim.flip_h = true
	elif Input.is_action_pressed("ui_down"):
		velocity.x = 0
	else:
		velocity.x = 0

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force

	if Input.is_action_pressed("shoot"):
		is_charging = true
		shoot_power = min(shoot_power + 40, max_power)
		power_bar.value = shoot_power
		power_bar.visible = true

	if Input.is_action_just_released("shoot"):
		is_charging = false
		shoot()
		shoot_power = 0
		power_bar.value = 0
		power_bar.visible = false

	if not is_on_floor():
		anim.play("jump")
	elif Input.is_action_pressed("ui_down"):
		anim.play("slide")
	elif is_charging:
		anim.play("shoot")
	elif velocity.x != 0:
		anim.play("run")
	else:
		anim.play("idle")

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var push_direction = collision.get_normal() * -1
			collider.apply_central_impulse(push_direction * 250)

func shoot():
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		var distance = global_position.distance_to(ball.global_position)
		if distance < 100:
			var direction = Vector2(1, -0.3)
			if shoot_power > 1500:
				direction.y = -1.0  # 풀차징 때 더 위로
			elif shoot_power > 800:
				direction.y = -0.6
			else:
				direction.y = -0.3
			if anim.flip_h:
				direction.x = -1
			ball.apply_central_impulse(direction * shoot_power * 1.5)
			get_node("/root/Main").play_ball_sound()
