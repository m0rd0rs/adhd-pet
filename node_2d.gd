extends Node2D

@onready var sprite: AnimatedSprite2D = $Pet
@onready var buzz_timer: Timer = $BuzzTimer
@onready var buzz_progress: ProgressBar = $"UI/Dinger/Visual Minutes"
@onready var buzz_minutes: Range = $UI/Dinger/Minutes
@onready var ringer: AudioStreamPlayer = $Ringer
var is_transparent: bool = true

func _ready() -> void:
	apply_transparency(is_transparent)
	OS.low_processor_usage_mode = true
	Engine.max_fps = 60 # make sure we don't clog the GPU with 
						# the transparency calculations
	sprite.set_flip_h(true)
	sprite.play(&"idle")

func _process(_delta: float) -> void:
	if !buzz_timer.is_stopped():
		buzz_progress.value = 100 / buzz_minutes.value * (buzz_timer.time_left / 60)

func update_click_boundary() -> void:
	if not sprite or not sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame):
		DisplayServer.window_set_mouse_passthrough([])
		return

	var img: Image = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_image()
	
	# Flip the image to match the AnimatedSprite2D's visual orientation
	if sprite.flip_h:
		img.flip_x()
	if sprite.flip_v:
		img.flip_y()

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


func play_ding() -> void:
	ringer.play()

func _on_ui_reality_check_toggle() -> void:
	buzz_timer.set_wait_time($UI/Dinger/Minutes.value * 60)
	if buzz_timer.is_stopped():
		buzz_timer.start()
	else:
		buzz_timer.stop()
		buzz_progress.value = 0 # reset it to zero, no need to implement "pause".


func _on_buzz_timer_timeout() -> void:
	play_ding()
