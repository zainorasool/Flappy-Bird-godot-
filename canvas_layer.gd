extends CanvasLayer

signal play




func _on_btn_pressed() -> void:
	play.emit()
