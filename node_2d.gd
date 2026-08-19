extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
var visible_window: bool = true

func _ready() -> void:
	toggle_transparency()
	update_click_boundary()
#	toggle_fullscreen()

func update_click_boundary() -> void:
	'Arrange the click-through for the pixels outside our pet'
	if sprite.texture:
		# Get the pixel data from your sprite image
		var img: Image = sprite.texture.get_image()
		
		# Create a bounding bitmap using the alpha/transparency layer of your artwork
		var bitmap: BitMap = BitMap.new()
		bitmap.create_from_image_alpha(img)
		
		# Trace a polygon wireframe snugly around the opaque pixels of your artwork
		var polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(
			Rect2(Vector2.ZERO, img.get_size()), 
			0.1 # Tolerance setting: Lower means a tighter, more precise click fit
		)
		
		# Translate the localized sprite polygon coordinates relative to the master system window
		if polygons.size() > 0:
			var local_poly: PackedVector2Array = polygons[0]
			var window_poly: PackedVector2Array = []
			
			# Compensate for where your sprite is sitting relative to the origin point
			var offset: Vector2 = sprite.global_position - (img.get_size() / 2.0) if sprite.centered else sprite.global_position
			
			for point in local_poly:
				window_poly.append(point + offset)
				
			# Hand the polygon mask directly over to Windows/Mac/Linux window manager
			DisplayServer.window_set_mouse_passthrough(window_poly)
		else:
			# If your sprite vanishes or is empty, make the entire window click-through
			DisplayServer.window_set_mouse_passthrough([])

func toggle_fullscreen() -> void:
	'Toggles fullscreen'
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func toggle_transparency() -> void:
	get_tree().root.transparent_bg = visible_window
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, visible_window)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, visible_window)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, visible_window)


func _on_pet_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			visible_window = !visible_window
			toggle_transparency()
			get_viewport().set_input_as_handled() 
