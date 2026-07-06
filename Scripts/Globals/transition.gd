extends CanvasLayer

@onready var _rect: ColorRect = $ColorRect

func _ready() -> void:
	layer = 100
	_rect.color = Color.BLACK
	_rect.modulate.a = 0.0
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Fade to opaque black.
func cover(duration: float = Constants.load_duration) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 1.0, duration)
	await tween.finished

## Fade back from black to transparent.
func reveal(duration: float = Constants.load_duration) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 0.0, duration)
	await tween.finished
