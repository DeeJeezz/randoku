extends Control
class_name FieldCell

@export_category("Nodes")
@export var button: Button
@export var animation_player: AnimationPlayer

var correct_value: int = 0
var current_value: int = 0
var field_position: Vector2i
var playable: bool = true

const VALID_ANIMATION_NAME: String = "valid_2"
const INVALID_ANIMATION_NAME: String = "invalid"
const INIT_ANIMATION_NAME: String = "init"


func init_value(value: int, can_play: bool) -> void:
	correct_value = value
	playable = can_play
	if not playable:
		current_value = correct_value
		_set_button_text(current_value)
		set_button_state(not playable)


func hide_value() -> void:
	if playable:
		_set_button_text(0)


func show_value() -> void:
	_set_button_text(correct_value)


func set_value(value: int) -> void:
	current_value = value
	_set_button_text(current_value)
	if value == 0:
		return


func check() -> bool:
	return current_value == correct_value


func set_button_state(disabled: bool) -> void:
	button.disabled = disabled


func set_field_position(row_idx: int, col_idx: int) -> void:
	field_position = Vector2i(row_idx, col_idx)


func play_valid_animation() -> void:
	animation_player.play(VALID_ANIMATION_NAME)


func play_invalid_animation() -> void:
	animation_player.play(INVALID_ANIMATION_NAME)


func play_init_animation() -> void:
	animation_player.play(INIT_ANIMATION_NAME)


func _set_button_text(value: int) -> void:
	if value == 0:
		button.text = ""
	else:
		button.text = "%s" % value
