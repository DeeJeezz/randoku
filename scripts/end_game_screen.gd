extends Control
class_name EndGameScreen


@export_category('Nodes')
@export_group('Labels')
@export var state_label: Label
@export var points_label: Label
@export var time_label: Label
@export_group('Button rows')
@export var next_level_row: HBoxContainer
@export_category('Settings')
@export var success_text: String
@export var fail_text: String


func show_screen(success: bool, time: String, points: int) -> void:
	visible = true
	time_label.text = '%s' % time
	points_label.text = '%s' % points
	
	if success:
		state_label.text = '%s' % success_text
		state_label.modulate = Color.GREEN
	else:
		state_label.text = '%s' % fail_text
		state_label.modulate = Color.RED
		next_level_row.visible = false
