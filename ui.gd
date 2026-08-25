extends CanvasLayer

signal reality_check_toggle()

@onready var reality_cycle: SpinBox = $Dinger/Minutes

func _on_toggle_reality_btn_pressed() -> void:
	reality_check_toggle.emit()
