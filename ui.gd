extends CanvasLayer

signal reality_check_toggle()

@onready var relity_cycle: SpinBox = $Dinger/Minutes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_toggle_reality_btn_pressed() -> void:
	reality_check_toggle.emit()
