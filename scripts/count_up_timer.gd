extends Timer
class_name CountUpTimer

@export_category("Nodes")
@export var timer_label: Label


class TimeCounter:
	var seconds: int
	var minutes: int
	var hours: int
	var total_seconds: int = (59 * 60) + 55

	func update_time() -> void:
		hours = int(float(total_seconds) / (60 * 60))
		minutes = int(float(total_seconds) / 60) - (hours * 60)
		seconds = total_seconds - (((hours * 60) + minutes) * 60)
		
	func count() -> void:
		total_seconds += 1
		update_time()
		
	func _append_zero(number: int) -> String:
		if number < 10:
			return '0%s' % number
		return str(number)
		
	func get_formatted_time(format: String = '%M:%S') -> String:
		var formatted_seconds: String = _append_zero(seconds)
		var formatted_minutes: String = _append_zero(minutes)
		var formatted_hours: String = _append_zero(hours)
		if hours > 0:
			format = '%%H:%s' % format
		return format.replace('%H', formatted_hours).replace('%M', formatted_minutes).replace('%S', formatted_seconds)


var counter: TimeCounter = TimeCounter.new()


func _ready() -> void:
	counter.update_time()
	_update_label()


func _on_timeout() -> void:
	counter.count()
	_update_label()


func _update_label() -> void:
	timer_label.text = counter.get_formatted_time()
