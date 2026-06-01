extends RigidBody2D

var start_pos = Vector2.ZERO
var should_reset = false
var reset_pos = Vector2.ZERO
var out_top_time = 0.0

func _ready():
	gravity_scale = 1.5
	start_pos = global_position

func reset_to(pos: Vector2):
	reset_pos = pos
	should_reset = true

func _physics_process(delta):
	if should_reset:
		should_reset = false
		global_position = reset_pos
		linear_velocity = Vector2.ZERO
		angular_velocity = 0

	if global_position.y < 180:
		out_top_time += delta
	else:
		out_top_time = 0.0

	if out_top_time >= 3.0:
		out_top_time = 0.0
		get_node("/root/Main").reset_positions()

	if global_position.y > 700 or global_position.x < -100 or global_position.x > 1300:
		get_node("/root/Main").reset_positions()
