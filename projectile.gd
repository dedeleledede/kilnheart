extends Area3D

@export var speed := 30.0
@export var warning_distance := 35.0

var direction := Vector3.ZERO
var lifetime := 0.0
var was_parried := false
var source_enemy: Node3D


func _ready() -> void:
	collision_layer = 1 << 4
	collision_mask = (1 << 1) | (1 << 2)

	monitoring = true
	monitorable = true

	body_entered.connect(on_body_entered)
	area_entered.connect(on_area_entered)
	
	add_to_group("hostile_projectile")


func set_target(
	target_position: Vector3,
	enemy: Node3D
) -> void:
	source_enemy = enemy
	direction = global_position.direction_to(
		target_position
	)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	lifetime += delta

	if lifetime >= 8.0:
		queue_free()


func parry() -> bool:
	if was_parried:
		return false

	was_parried = true
	remove_from_group("hostile_projectile")
	direction = -direction
	speed *= 1.7
	scale = Vector3.ONE * 1.5

	return true


func on_body_entered(body: Node3D) -> void:
	if was_parried:
		return

	if body.has_method("die"):
		body.die()
		queue_free()

func on_area_entered(area: Area3D) -> void:
	if not was_parried:
		return

	if area.has_method("receive_parried_projectile"):
		area.call("receive_parried_projectile", self)
		queue_free()
		
func should_warn(
	player_position: Vector3,
	camera: Camera3D
) -> bool:
	if was_parried:
		return false

	if not is_instance_valid(source_enemy):
		return false

	if not camera.is_position_behind(
		source_enemy.global_position
	):
		return false

	return global_position.distance_to(
		player_position
	) <= warning_distance
