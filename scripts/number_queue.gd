extends Control
class_name NumberQueue

@export_category("Nodes")
@export var skip_button: Button
@export var place_number_button: Button
@export var queue_container: HBoxContainer
@export_category("Settings")
@export var queue_size: int = 3

var queue: Array[int] = []

const QUEUE_NUMBER_SCENE: PackedScene = preload("res://scenes/queue_number.tscn")
var NUMBERS: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]

func setup() -> void:
	for number in range(queue_size):
		queue.append(_get_random_value())

	_setup_ui()
	_update_ui()


func _get_random_value() -> int:
	return NUMBERS.pick_random()


func _setup_ui() -> void:
	for child in queue_container.get_children():
		queue_container.remove_child(child)
		child.queue_free()

	for idx in range(queue_size):
		var queue_number: Control = QUEUE_NUMBER_SCENE.instantiate()
		if idx == 0:
			queue_number.modulate = Color.YELLOW
		queue_container.add_child(queue_number)


func _update_ui() -> void:
	for child_idx in range(len(queue_container.get_children())):
		var child = queue_container.get_child(child_idx)
		if child is QueueNumber:
			child.set_value(queue[child_idx])


func _pop_queue_front_value() -> int:
	var value: int = queue.pop_front()
	queue.append(_get_random_value())
	return value


func skip() -> void:
	_pop_queue_front_value()
	_update_ui()


func get_current_value() -> int:
	return queue[0]


func pop_current_value() -> int:
	var result = _pop_queue_front_value()
	_update_ui()
	return result

	
func rebuild_without(number: int) -> void:
	# Clear number occurencies in queue.
	while queue.has(number):
		queue.erase(number)
	# Remove number from possible queue variations.
	NUMBERS.erase(number)
	
	# Game end.
	if len(NUMBERS) == 0:
		Signals.game_end.emit(true)
		return
	
	# Append missing numbers.
	for _i in queue_size - len(queue):
		queue.append(_get_random_value())
		
	_update_ui()
	print('Removed ', number, ' from queue')
