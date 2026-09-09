extends CharacterBody3D

@export var maximum_forward_speed := 10.0
@export var forward_acceleration := 14.0

@export var lateral_speed := 7.0
@export var lateral_acceleration := 24.0

@export var dodge_speed := 40.0
@export var dodge_duration := 0.15
@export var dodge_cooldown := 0.45

@export var jump_velocity := 7.0
@export var gravity := 20.0

var dodge_time_left := 0.0
var dodge_cooldown_left := 0.0
var dodge_direction := 1.0
var last_lateral_direction := 1.0

var air_dodge_available := true

var dead := false


func _ready() -> void:
	collision_layer = 1 << 1
	collision_mask = 1 << 0


func _physics_process(delta: float) -> void:
	if is_on_floor():
		air_dodge_available = true

	var lateral_input := Input.get_axis("move_left", "move_right")

	update_dodge(delta, lateral_input)
	update_forward_movement(delta)
	update_vertical_movement(delta)

	move_and_slide()
	check_fatal_collisions()


func update_dodge(delta: float, lateral_input: float) -> void:
	dodge_cooldown_left = max(dodge_cooldown_left - delta, 0.0)

	if abs(lateral_input) > 0.1:
		last_lateral_direction = sign(lateral_input)

	var can_dodge := is_on_floor() or air_dodge_available

	if (
		Input.is_action_just_pressed("dodge")
		and dodge_cooldown_left <= 0.0
		and can_dodge
	):
		dodge_direction = last_lateral_direction
		dodge_time_left = dodge_duration
		dodge_cooldown_left = dodge_cooldown

		if not is_on_floor():
			air_dodge_available = false

	if dodge_time_left > 0.0:
		var progress := 1.0 - dodge_time_left / dodge_duration
		var dodge_strength := 1.0 - progress
		var control_strength := progress * progress

		velocity.x = (
			dodge_direction * dodge_speed * dodge_strength
			+ lateral_input * lateral_speed * control_strength
		)

		dodge_time_left = max(dodge_time_left - delta, 0.0)
	else:
		velocity.x = move_toward(
			velocity.x,
			lateral_input * lateral_speed,
			lateral_acceleration * delta
		)


func update_forward_movement(delta: float) -> void:
	velocity.z = move_toward(
		velocity.z,
		-maximum_forward_speed,
		forward_acceleration * delta
	)


func update_vertical_movement(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		else:
			velocity.y = -0.5
	else:
		velocity.y -= gravity * delta


func check_fatal_collisions() -> void:
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var collider := collision.get_collider() as Node

		if collider == null:
			continue

		var fatal := collider.is_in_group("fatal_obstacle")

		if not fatal and collider.get_parent() != null:
			fatal = collider.get_parent().is_in_group("fatal_obstacle")

		if fatal:
			die()
			return


func die() -> void:
	if dead:
		return

	dead = true
	set_physics_process(false)
	$MeshInstance3D.visible = false

	await get_tree().create_timer(0.4).timeout
	get_tree().reload_current_scene()
