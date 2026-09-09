extends Area3D


func _ready() -> void:
	collision_layer = 1 << 2
	collision_mask = 0
	monitorable = true


func receive_parried_projectile(_projectile: Area3D) -> void:
	var enemy := get_parent()

	if enemy.has_method("take_hit"):
		enemy.call("take_hit")
