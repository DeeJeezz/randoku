extends Node2D

@export_category("Game nodes")
@export var board: Board
@export var number_queue: NumberQueue
@export_category("UI nodes")
@export var points_label: Label
@export var add_point_label: Label
@export var timer_label: Label
@export var end_game_screen: EndGameScreen
@export_category("Settings")
@export var game_seed: int = 0
@export var level_id: String = "1"
@export var add_points_delay: float = 1.0
@export var add_points_fadeout_delay: float = 0.75
@export var base_cell_points: int = 100

var chosen_cell: FieldCell = null

var points: int = 0


func _ready() -> void:
	# Setup rng seed before level initialization.
	seed(game_seed)
	# UI setup
	end_game_screen.visible = false
	add_point_label.modulate.a = 0
	points_label.text = "%s" % points
	# Game setup.
	board.setup(level_id)
	number_queue.setup()
	
	# Remove from number queue pool non playable numbers.
	_clear_number_queue()

	# Signals connectors.
	number_queue.skip_button.connect("pressed", _on_skip_button_pressed)
	number_queue.place_number_button.connect("pressed", _on_place_number_button_pressed)
	Signals.field_cell_pressed.connect(_on_field_cell_pressed)
	Signals.game_end.connect(_on_game_end)


#region Signals processing
func _on_game_end(success: bool) -> void:
	print('Game end: ', success)
	if success:
		end_game_success()
	else:
		end_game_fail()


func _on_skip_button_pressed() -> void:
	number_queue.skip()


func _on_field_cell_pressed(cell: FieldCell) -> void:
	board.highlight_cells(cell)
	if cell.playable:
		chosen_cell = cell


func _on_place_number_button_pressed() -> void:
	if chosen_cell == null:
		return

	if not chosen_cell.playable:
		return

	if chosen_cell.check():
		return

	var rng_value: int = number_queue.pop_current_value()
	chosen_cell.set_value(rng_value)
	var is_cell_valid: bool = board.validate_cell(chosen_cell)
	if is_cell_valid:
		var amount_of_checks_passed: int = board.recalculate_field(chosen_cell)
		var total_points_to_add: int = base_cell_points + base_cell_points * amount_of_checks_passed
		_add_points(total_points_to_add)

		if board.check_last_number(rng_value):
			number_queue.rebuild_without(rng_value)


#endregion


#region UI
func _add_points(add_points: int) -> void:
	points += add_points
	var tween = get_tree().create_tween()
	tween.tween_property(add_point_label, "modulate:a", 1, add_points_fadeout_delay)
	add_point_label.text = "%s +" % add_points
	await get_tree().create_timer(add_points_delay).timeout
	tween = get_tree().create_tween()
	tween.tween_property(add_point_label, "modulate:a", 0, add_points_fadeout_delay)
	points_label.text = "%s" % points


#endregion


func _clear_number_queue() -> void:
	var exhausted_numbers: Array[int] = []
	for number in number_queue.NUMBERS:
		if board.check_last_number(number):
			exhausted_numbers.append(number)
	for number in exhausted_numbers:
		number_queue.rebuild_without(number)


func end_game_success() -> void:
	end_game_screen.show_screen(true, timer_label.text, points)


func end_game_fail() -> void:
	end_game_screen.show_screen(false, timer_label.text, points)
