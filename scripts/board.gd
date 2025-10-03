extends Control
class_name Board

@export_category("Field nodes")
@export var rows: Array[HBoxContainer]
@export_category("Settings")
@export var field_cell_animation_delay: float = 0.05

const BLOCK_SIZE: int = 3
const LEVELS_PATH: String = "res://configs/levels/levels.json"
const EMPTY_FIELD_MARKER: int = 0

var _field_cells = []

func _ready() -> void:
	_init_level_from_file()


#region Level instantiation
func _read_level_from_file() -> Array:
	var file := FileAccess.open(LEVELS_PATH, FileAccess.READ)
	var file_content = file.get_as_text()
	var levels_data: Dictionary = JSON.parse_string(file_content)

	return levels_data["1"]


func _init_level_from_file() -> void:
	var levels_data: Array = _read_level_from_file()
	levels_data = levels_data.map(func(r): return r.map(func(c): return int(c)))
	for row_idx in range(len(levels_data)):
		var row: Array[FieldCell] = []
		for field_cell in rows[row_idx].get_children():
			if field_cell is FieldCell:
				row.append(field_cell)

		for col_idx in range(len(levels_data[row_idx])):
			var cell: FieldCell = row[col_idx]
			if levels_data[row_idx][col_idx] > 0:
				cell.init_value(levels_data[row_idx][col_idx], false)
			else:
				cell.init_value(abs(levels_data[row_idx][col_idx]), true)
				_connect_button_to_signal_processor(cell)
			cell.set_field_position(row_idx, col_idx)
			cell.play_init_animation()
		_field_cells.append(row)


#endregion


#region Signals processing
func _on_field_button_pressed(cell: FieldCell) -> void:
	pass
	#if clear_mode:
	#_set_cell_value(cell.field_position.x, cell.field_position.y, 0)
	#_set_player_buttons_state(true)
	#clear_mode = false
	#return


#
#if _current_rng_number == 0:
#return
#print("Pressed button ", cell.button)
#_set_cell_value(cell.field_position.x, cell.field_position.y, _current_rng_number)
#_current_rng_number = 0
#_set_player_buttons_state(true)
#recalculate_field(cell.field_position.x, cell.field_position.y)


func _connect_button_to_signal_processor(cell: FieldCell) -> void:
	cell.button.pressed.connect(_on_field_button_pressed.bind(cell))


#endregion


#region Cells manipulation
func _get_cell(row_idx: int, col_idx: int) -> FieldCell:
	return _field_cells[row_idx][col_idx]


func _get_row(row_idx: int) -> Array[FieldCell]:
	return _field_cells[row_idx]


func _get_col(col_idx: int) -> Array[FieldCell]:
	var result: Array[FieldCell] = []
	for row_idx in range(len(_field_cells)):
		result.append(_field_cells[row_idx][col_idx])
	return result


func _get_block(row_idx: int, col_idx: int) -> Array[FieldCell]:
	var block_coord: Vector2i = Vector2i(
		int((row_idx / BLOCK_SIZE) * BLOCK_SIZE),
		int((col_idx / BLOCK_SIZE) * BLOCK_SIZE),
	)
	# Выбираем блок и разворачиваем его в строку.
	var block_cells: Array[FieldCell] = []
	for row in range(block_coord.x, block_coord.x + BLOCK_SIZE):
		for col in range(block_coord.y, block_coord.y + BLOCK_SIZE):
			block_cells.append(_field_cells[row][col])
	return block_cells


func _set_cell_value(row_idx: int, col_idx: int, value: int) -> void:
	var cell: FieldCell = _get_cell(row_idx, col_idx)
	cell.set_value(value)


func __generic_get_values(f: Callable, row_idx: Variant = null, col_idx: Variant = null) -> Array[int]:
	var args = []
	if row_idx != null and col_idx == null:
		args = [row_idx]
	elif row_idx == null and col_idx != null:
		args = [col_idx]
	elif row_idx != null and col_idx != null:
		args = [row_idx, col_idx]
	else:
		push_error("Inapropriate usage of function")
	var arr: Array[FieldCell] = f.callv(args)
	var result: Array[int] = []
	for cell in arr:
		result.append(int(cell.current_value))
	return result


func _get_row_values(row_idx: int) -> Array[int]:
	return __generic_get_values(_get_row, row_idx, null)


func _get_col_values(col_idx: int) -> Array[int]:
	return __generic_get_values(_get_col, null, col_idx)


func _get_block_values(row_idx: int, col_idx: int) -> Array[int]:
	return __generic_get_values(_get_block, row_idx, col_idx)


#endregion


#region Field calculations
func _base_validation(values: Array[int]) -> bool:
	if EMPTY_FIELD_MARKER in values:
		print("Empty marker in ", values)
		return false

	var unique_numbers: Array[int] = []
	for number in values:
		if number in unique_numbers:
			print("Not unique number: ", values)
			return false
		unique_numbers.append(number)

	if len(unique_numbers) != BLOCK_SIZE * BLOCK_SIZE:
		print("Length not equal 9: ", unique_numbers)
		return false

	return true


func _validate_row(row_idx: int) -> bool:
	var row_values: Array[int] = _get_row_values(row_idx)
	return _base_validation(row_values)


func _validate_col(col_idx: int) -> bool:
	var col_values: Array[int] = _get_col_values(col_idx)
	return _base_validation(col_values)


func _validate_block(row_idx: int, col_idx: int) -> bool:
	var block_values: Array[int] = _get_block_values(row_idx, col_idx)
	return _base_validation(block_values)


func _play_valid_animation(cells: Array[FieldCell]) -> void:
	for cell in cells:
		cell.play_valid_animation()
		await get_tree().create_timer(field_cell_animation_delay).timeout


func recalculate_field(row_idx: int, col_idx: int) -> void:
	var row_valid: bool = _validate_row(row_idx)
	print("Row valid: ", row_valid)
	if row_valid:
		var cells: Array[FieldCell] = _get_row(row_idx)
		_play_valid_animation(cells)
	var col_valid: bool = _validate_col(col_idx)
	print("Col valid: ", col_valid)
	if col_valid:
		var cells: Array[FieldCell] = _get_col(col_idx)
		_play_valid_animation(cells)
	var block_valid: bool = _validate_block(row_idx, col_idx)
	print("Block valid: ", block_valid)
	if block_valid:
		var cells: Array[FieldCell] = _get_block(row_idx, col_idx)
		_play_valid_animation(cells)


#endregion


#region Field preparation and processing
func _set_player_buttons_state(disabled: bool) -> void:
	for row in _field_cells:
		for field_cell in row:
			if field_cell.playable:
				field_cell.set_button_state(disabled)

#endregion
