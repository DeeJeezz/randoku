extends Control
class_name FieldCell

@export_category("Nodes")
@export var button: Button
@export var animation_player: AnimationPlayer
@export_category("UI")
@export_group("Theme type variations")
@export_subgroup("Normal")
@export var playable_normal_theme: String
@export var not_playable_normal_theme: String
@export var valid_normal_theme: String
@export var invalid_normal_theme: String
@export_group("Animations")
@export var valid_animation: String
@export var invalid_animation: String
@export var init_animation: String

var correct_value: int = 0
var current_value: int = 0
var field_position: Vector2i
var playable: bool = true


func check() -> bool:
	return current_value == correct_value


#region Setup
func init_value(value: int, can_play: bool) -> void:
	_set_button_text(0)
	correct_value = value
	playable = can_play
	var type_variation: String = playable_normal_theme
	if not playable:
		type_variation = not_playable_normal_theme
		current_value = correct_value
		_set_button_text(current_value)

	_set_theme_variation(type_variation)

	button.pressed.connect(_on_button_pressed)


#endregion


#region Signals processing
func _on_button_pressed() -> void:
	Signals.field_cell_pressed.emit(self)

#endregion


#region Setters
func set_value(value: int) -> void:
	current_value = value
	_set_button_text(current_value)
	if value == 0:
		return


func set_field_position(row_idx: int, col_idx: int) -> void:
	field_position = Vector2i(row_idx, col_idx)


func _set_button_text(value: int) -> void:
	if value == 0:
		button.text = ""
	else:
		button.text = "%s" % value


func _set_theme_variation(variation_name: String) -> void:
	button.theme_type_variation = variation_name


#endregion


#region Animations
func play_valid_animation() -> void:
	animation_player.play(valid_animation)
	_set_theme_variation(valid_normal_theme)


func play_invalid_animation() -> void:
	animation_player.play(invalid_animation)
	_set_theme_variation(invalid_normal_theme)


func play_init_animation() -> void:
	animation_player.play(init_animation)

#endregion


func highlight() -> void:
	button.set_pressed_no_signal(true)
	
	
func disable_highlight() -> void:
	button.set_pressed_no_signal(false)
	
