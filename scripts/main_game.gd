extends Node2D

@export_category('Game nodes')
@export var board: Board
@export var number_queue: NumberQueue
@export_category("UI nodes")
@export var points_label: Label
@export_category("Settings")
@export var game_seed: int = 0


func _ready() -> void:
	seed(game_seed)
	number_queue.skip_button.connect('pressed', _on_skip_button_pressed)
	Signals.field_cell_pressed.connect(_on_field_cell_pressed)


func _on_skip_button_pressed() -> void:
	number_queue.skip()
	
	
func _on_field_cell_pressed(cell: FieldCell) -> void:
	var rng_value: int = number_queue.pop_current_value()
	cell.set_value(rng_value)
	board.recalculate_field(cell)
