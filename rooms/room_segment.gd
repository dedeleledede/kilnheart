extends Node3D
class_name RoomSegment

signal exit_reached(room)

@export var room_length := 80.0

@onready var entry_marker: Marker3D = $EntryMarker
@onready var exit_marker: Marker3D = $ExitMarker
@onready var exit_trigger: Area3D = $ExitTrigger


func _ready() -> void:
	exit_trigger.body_entered.connect(
		_on_exit_trigger_body_entered
	)


func get_entry_position() -> Vector3:
	return entry_marker.global_position


func get_exit_position() -> Vector3:
	return exit_marker.global_position


func _on_exit_trigger_body_entered(
	body: Node3D
) -> void:
	if not body.is_in_group("player"):
		return

	exit_trigger.set_deferred(
		"monitoring",
		false
	)

	exit_reached.emit(self)
