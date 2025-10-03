extends Control


@export_category('Nodes')
@export var skip_button: Button
@export var queue_container: Control
@export_category('Settings')
@export var queue_size: int = 3

var queue: Array[int] = []


const QUEUE_NUMBER_SCENE: PackedScene = preload('res://scenes/queue_number.tscn')


func _ready() -> void:
	for number in range(queue_size):
		queue.append(randi_range(1, 9))
		
	_setup_ui()
	_update_ui()


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


func _on_skip_button_pressed() -> void:
	_get_queue_front_value()
	_update_ui()


func _get_queue_front_value() -> int:
	var value: int = queue.pop_front()
	queue.append(randi_range(1, 9))
	return value
