extends Area3D

@export var speed := 32.0
@export var damage := 1
@export var maximum_lifetime := 3.0

var direction := Vector3.FORWARD
var lifetime := 0.0
var spent := false


func _ready() -> void:
	collision_layer = 1 << 6

	collision_mask = (
		(1 << 0)
		| (1 << 2)
	)

	monitoring = true
	monitorable = true

	area_entered.connect(
		on_area_entered
	)

	body_entered.connect(
		on_body_entered
	)


func configure(
	new_direction: Vector3
) -> void:
	if new_direction.length_squared() <= 0.0:
		return

	direction = new_direction.normalized()

	look_at(
		global_position + direction,
		Vector3.UP
	)


func _physics_process(delta: float) -> void:
	global_position += (
		direction
		* speed
		* delta
	)

	lifetime += delta

	if lifetime >= maximum_lifetime:
		queue_free()


func on_area_entered(area: Area3D) -> void:
	if spent:
		return

	if not area.has_method(
		"receive_player_projectile"
	):
		return

	spent = true

	area.call(
		"receive_player_projectile",
		damage
	)

	queue_free()


func on_body_entered(_body: Node3D) -> void:
	if spent:
		return

	spent = true
	queue_free()
