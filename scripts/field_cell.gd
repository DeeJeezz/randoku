extends Control
class_name FieldCell

@export_category('Nodes')
@export var button: Button
@export var animation_player: AnimationPlayer

var current_value: int = 0
var field_position: Vector2i
var playable: bool = true

const VALID_ANIMATION_NAME: String = 'valid'


func set_value(value: int) -> void:
	current_value = value
	if value > 0:
		button.text = '%s' % value
	else:
		button.text = ''


func get_value() -> int:
	return current_value
	
	
func set_button_state(disabled: bool) -> void:
	button.disabled = disabled
	
	
func set_field_position(row_idx: int, col_idx: int) -> void:
	field_position = Vector2i(row_idx, col_idx)


func play_animation() -> void:
	animation_player.play(VALID_ANIMATION_NAME)
