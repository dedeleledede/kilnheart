extends Node3D
class_name RoomSegment

@export var room_length := 80.0

@onready var entry_marker: Marker3D = $EntryMarker
@onready var exit_marker: Marker3D = $ExitMarker


func get_entry_position() -> Vector3:
	return entry_marker.global_position


func get_exit_position() -> Vector3:
	return exit_marker.global_position
