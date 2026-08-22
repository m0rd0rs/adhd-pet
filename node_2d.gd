extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
var is_transparent: bool = true

func _ready() -> void:
	apply_transparency(is_transparent)

func update_click_boundary() -> void:
	if not sprite or not sprite.texture:
		DisplayServer.window_set_mouse_passthrough([])
		return
		
	var img: Image = sprite.texture.get_image()
	var bitmap: BitMap = BitMap.new()
	bitmap.create_from_image_alpha(img)
	
	var polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(
		Rect2(Vector2.ZERO, img.get_size()), 
		0.1
	)
	
	if polygons.size() > 0:
		var local_poly: PackedVector2Array = polygons[0]
		var window_poly: PackedVector2Array = []
		
		# Offset for center if sprite is centered
		var origin_offset: Vector2 = -(img.get_size() / 2.0) if sprite.centered else Vector2.ZERO
		
		for point in local_poly:
			# Convert local sprite pixel position to global/viewport coordinates
			var global_pt: Vector2 = sprite.to_global(point + origin_offset)
			# Convert viewport coordinates to OS window pixel coordinates
			var window_pt: Vector2 = get_viewport().get_final_transform() * global_pt
			window_poly.append(window_pt)
			
		DisplayServer.window_set_mouse_passthrough(window_poly)
	else:
		# Empty array disables passthrough (whole window accepts clicks)
		DisplayServer.window_set_mouse_passthrough([])

func apply_transparency(transparent: bool) -> void:
	# 1. Update viewport background
	get_viewport().transparent_bg = transparent
	get_tree().root.transparent_bg = transparent
	
	# 2. Update window flags
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, transparent)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, transparent)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, transparent)
	
	# 3. Update mouse passthrough
	if transparent:
		# Defer boundary update to ensure window size & transforms have settled
		update_click_boundary.call_deferred()
	else:
		# In opaque/windowed mode, disable passthrough so window & titlebar are clickable
		DisplayServer.window_set_mouse_passthrough([])

func toggle_transparency() -> void:
	is_transparent = !is_transparent
	apply_transparency(is_transparent)

func _on_pet_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_transparency()
			get_viewport().set_input_as_handled() 

"""
  ### Review the Summary of Changes:

  1. Dynamic Passthrough Management (node_2d.gd:42-58):
      • Calling DisplayServer.window_set_mouse_passthrough([])
      file:///C:/Users/mordor/Godot/pet-project/node_2d.gd#L58 when switching to
      opaque/windowed mode, ensuring the entire window, borders, and pet remain clickable.
      • Calling node_2d.gd:9-40 via .call_deferred() when switching to transparent mode so
      the mask accurately bounds the pet.
  2. Accurate Coordinates (node_2d.gd:30-36):
      • Converts the sprite's polygon vertices using sprite.to_global() and get_viewport().
      get_final_transform(), preventing offset errors caused by scaling or viewport stretch.
  3. State Consistency:
      • Uses is_transparent to clearly track whether the desktop pet overlay mode is active.
"""
