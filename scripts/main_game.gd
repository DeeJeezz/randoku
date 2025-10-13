extends Node2D

@export_category('Game nodes')
@export var board: Board
@export var number_queue: NumberQueue
@export_category("UI nodes")
@export var points_label: Label
@export var add_point_label: Label
@export_category("Settings")
@export var game_seed: int = 0
@export var level_id: String = "1"
@export var add_points_delay: float = 1.0
@export var add_points_fadeout_delay: float = 0.75
@export var base_cell_points: int = 100

var points: int = 0

func _ready() -> void:
	# Setup rng seed before level initialization.
	seed(game_seed)
	# UI setup
	add_point_label.modulate.a = 0
	points_label.text = '%s' % points
	# Game setup.
	board.setup(level_id)
	number_queue.setup()
	# Signals.
	number_queue.skip_button.connect('pressed', _on_skip_button_pressed)
	Signals.field_cell_pressed.connect(_on_field_cell_pressed)


func _on_skip_button_pressed() -> void:
	number_queue.skip()
	
	
func _on_field_cell_pressed(cell: FieldCell) -> void:
	board.highlight_cells(cell)
	if not cell.playable:
		return
		
	if cell.check():
		return
	
	var rng_value: int = number_queue.pop_current_value()
	cell.set_value(rng_value)
	var is_cell_valid: bool = board.validate_cell(cell)
	if is_cell_valid:
		var checks_passed: int = board.recalculate_field(cell)
		var total_points_to_add: int = base_cell_points + base_cell_points * checks_passed
		_add_points(total_points_to_add)
		
		
#region UI
func _add_points(add_points: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(add_point_label, 'modulate:a', 1, add_points_fadeout_delay)
	add_point_label.text = '%s +' % add_points
	await get_tree().create_timer(add_points_delay).timeout
	tween = get_tree().create_tween()
	tween.tween_property(add_point_label, 'modulate:a', 0, add_points_fadeout_delay)
	points += add_points
	points_label.text = '%s' % points

#endregion
