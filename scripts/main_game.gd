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


func _on_skip_button_pressed() -> void:
	number_queue.skip()
