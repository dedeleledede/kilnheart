extends Node3D
class_name RunGenerator

@export var room_scenes: Array[PackedScene] = []
@export var starting_room_count: int = 3
@export var maximum_active_rooms: int = 4

var rooms: Array[RoomSegment] = []

var next_room_id := 0
var last_room_scene_index := -1

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	for index: int in range(starting_room_count):
		spawn_room()


func spawn_room() -> void:
	var selected_scene := pick_room_scene()

	if selected_scene == null:
		return

	var new_room := (
		selected_scene.instantiate()
		as RoomSegment
	)

	if new_room == null:
		push_error(
			"Room scene must use RoomSegment."
		)
		return

	new_room.name = "Room_%d" % next_room_id
	next_room_id += 1

	add_child(new_room)

	if rooms.is_empty():
		new_room.global_position = Vector3.ZERO
	else:
		var previous_room: RoomSegment = (
			rooms.back() as RoomSegment
		)	

		new_room.global_position = Vector3.ZERO

		var offset := (
			previous_room.get_exit_position()
			- new_room.get_entry_position()
		)

		new_room.global_position += offset

	new_room.exit_reached.connect(
		_on_room_exit_reached
	)

	rooms.append(new_room)


func pick_room_scene() -> PackedScene:
	if room_scenes.is_empty():
		push_error(
			"RunGenerator has no room scenes."
		)
		return null

	if room_scenes.size() == 1:
		last_room_scene_index = 0
		return room_scenes[0]

	var selected_index := rng.randi_range(
		0,
		room_scenes.size() - 1
	)

	while selected_index == last_room_scene_index:
		selected_index = rng.randi_range(
			0,
			room_scenes.size() - 1
		)

	last_room_scene_index = selected_index

	return room_scenes[selected_index]


func _on_room_exit_reached(
	_room: RoomSegment
) -> void:
	spawn_room()
	remove_old_rooms()


func remove_old_rooms() -> void:
	while rooms.size() > maximum_active_rooms:		
		var old_room: RoomSegment = (
			rooms.pop_front() as RoomSegment
		)

		if is_instance_valid(old_room):
			old_room.queue_free()
