extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# 1. Cleanly initialize the background transparency via code to ensure system hookup
	get_viewport().transparent_bg = true # 2.1.1, 2.2.5
	
	# 2. Automatically generate the click boundary around your actual sprite image
	update_click_boundary()

func update_click_boundary() -> void:
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
