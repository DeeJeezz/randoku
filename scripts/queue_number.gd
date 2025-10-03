extends TextureRect
class_name QueueNumber


@export_category('Nodes')
@export var label: Label


func set_value(value: int) -> void:
	label.text = '%s' % value
