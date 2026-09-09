extends Node3D
class_name RunGenerator

@export var room_scene: PackedScene
@export var starting_room_count: int = 3

var rooms: Array[RoomSegment] = []


func _ready() -> void:
	for index: int in range(starting_room_count):
		spawn_room()


func spawn_room() -> void:
	var new_room: RoomSegment = (
		room_scene.instantiate() as RoomSegment
	)

	if new_room == null:
		push_error("Room scene must use RoomSegment.")
		return

	new_room.name = "Room_%d" % rooms.size()
	add_child(new_room)

	if rooms.is_empty():
		new_room.global_position = Vector3.ZERO
	else:
		var previous_room: RoomSegment = (
			rooms.back() as RoomSegment
		)

		new_room.global_position = Vector3.ZERO

		var offset: Vector3 = (
			previous_room.get_exit_position()
			- new_room.get_entry_position()
		)

		new_room.global_position += offset

	rooms.append(new_room)
