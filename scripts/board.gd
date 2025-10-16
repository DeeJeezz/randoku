extends Control
class_name Board

@export_category("Field nodes")
@export var rows: Array[HBoxContainer]
@export_category("Settings")
@export var field_cell_animation_delay: float = 0.05

const BLOCK_SIZE: int = 3
const LEVELS_PATH: String = "res://configs/levels/levels.json"
const EMPTY_FIELD_MARKER: int = 0

var _field_cells: Array = []


func setup(level_id: String) -> void:
	_init_level_from_file(level_id)


#region Level instantiation
func _read_level_from_file(level_id: String) -> Array:
	var file := FileAccess.open(LEVELS_PATH, FileAccess.READ)
	var file_content = file.get_as_text()
	var levels_data: Dictionary = JSON.parse_string(file_content)

	return levels_data[level_id]


func _init_level_from_file(level_id: String) -> void:
	var levels_data: Array = _read_level_from_file(level_id)
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
			cell.set_field_position(row_idx, col_idx)
			cell.play_init_animation()
		_field_cells.append(row)


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


#endregion


#region Field calculations
func _base_cells_validation(cells: Array[FieldCell]) -> bool:
	var checks: Array = []
	for cell in cells:
		if cell.current_value != 0:
			checks.append(cell.check())
		else:
			checks.append(null)

	return false not in checks and null not in checks


func _validate_row(row_idx: int) -> bool:
	var row: Array[FieldCell] = _get_row(row_idx)
	return _base_cells_validation(row)


func _validate_col(col_idx: int) -> bool:
	var col: Array[FieldCell] = _get_col(col_idx)
	return _base_cells_validation(col)


func _validate_block(row_idx: int, col_idx: int) -> bool:
	var block: Array[FieldCell] = _get_block(row_idx, col_idx)
	return _base_cells_validation(block)


func recalculate_field(cell: FieldCell) -> int:
	var start_time = Time.get_ticks_usec()
	# Returns amount of passed checks.
	var checks_passed: int = 0
	var row_valid: bool = _validate_row(cell.field_position.x)
	print("Row valid: ", row_valid)
	if row_valid:
		checks_passed += 1
		var cells: Array[FieldCell] = _get_row(cell.field_position.x)
		_play_valid_animation(cells)
	var col_valid: bool = _validate_col(cell.field_position.y)
	print("Col valid: ", col_valid)
	if col_valid:
		checks_passed += 1
		var cells: Array[FieldCell] = _get_col(cell.field_position.y)
		_play_valid_animation(cells)
	var block_valid: bool = _validate_block(cell.field_position.x, cell.field_position.y)
	print("Block valid: ", block_valid)
	if block_valid:
		checks_passed += 1
		var cells: Array[FieldCell] = _get_block(cell.field_position.x, cell.field_position.y)
		_play_valid_animation(cells)
		
	print('Recalculate time mcs: ', Time.get_ticks_usec() - start_time)
		
	return checks_passed


func validate_cell(cell: FieldCell) -> bool:
	var is_cell_valid: bool = cell.check()
	if is_cell_valid:
		cell.play_valid_animation()
	else:
		cell.play_invalid_animation()
	return is_cell_valid


func check_last_number(number: int) -> bool:
	var counter: int = 0
	for row in _field_cells:
		for col in row:
			if col.current_value == number and col.check():
				counter += 1
				
	return counter == BLOCK_SIZE * BLOCK_SIZE

#endregion


#region UI
func _play_valid_animation(cells: Array[FieldCell]) -> void:
	for cell in cells:
		cell.play_valid_animation()
		await get_tree().create_timer(field_cell_animation_delay).timeout


func _disable_highlight(cells: Array[FieldCell]) -> void:
	for cell in cells:
		cell.disable_highlight()


func highlight_cells(current_cell: FieldCell) -> void:
	for row in _field_cells:
		_disable_highlight(row)
	var cells_to_highlight: Array[FieldCell] = [current_cell]
	# TODO: Подумать, как исключить одинаковые ячейки.
	cells_to_highlight.append_array(_get_row(current_cell.field_position.x))
	cells_to_highlight.append_array(_get_col(current_cell.field_position.y))
	cells_to_highlight.append_array(_get_block(current_cell.field_position.x, current_cell.field_position.y))

	for cell in cells_to_highlight:
		cell.highlight()
	
	for row in _field_cells:
		for cell: FieldCell in row:
			if cell.current_value != 0 and cell.current_value == current_cell.current_value:
				cell.highlight()
			
#endregion
