extends Node2D

@onready var sprite: AnimatedSprite2D = $Pet
@onready var buzz_timer: Timer = $BuzzTimer
@onready var buzz_progress: ProgressBar = $"UI/Dinger/Visual Minutes"
@onready var buzz_minutes: Range = $UI/Dinger/Minutes
@onready var ringer: AudioStreamPlayer = $Ringer
@onready var speech_label: Label = $Cheer

var is_transparent: bool = true
var active_tween: Tween
var messages: Array[String] = [
	"Keep going!\nYou're doing great.",
	"Remember to hydrate!",
	"Take a quick stretch break.",
	"One step at a time!"
]

func _ready() -> void:
	speech_label.modulate.a = 0.0
	apply_transparency(is_transparent)
	OS.low_processor_usage_mode = true
	Engine.max_fps = 60 # make sure we don't clog the GPU with 
						# the transparency calculations
	sprite.set_flip_h(true)
	sprite.play(&"idle")

func _process(_delta: float) -> void:
	if !buzz_timer.is_stopped():
		buzz_progress.value = 100 / buzz_minutes.value * (buzz_timer.time_left / 60)

func update_click_boundary(include_speech: bool = false) -> void:
	if not is_transparent:
		DisplayServer.window_set_mouse_passthrough([])
		return

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
		Rect2(Vector2.ZERO, img.get_size()), 0.1)

	if polygons.size() > 0:
		var local_poly: PackedVector2Array = polygons[0]
		var window_poly: PackedVector2Array = []
		
		# Offset for center if sprite is centered
		var origin_offset: Vector2 = -(img.get_size() / 2.0) if sprite.centered else Vector2.ZERO
		var xform: Transform2D = get_viewport().get_final_transform()
		
		for point in local_poly:
			# Convert local sprite pixel position to global/viewport coordinates
			var global_pt: Vector2 = sprite.to_global(point + origin_offset)
			# Convert viewport coordinates to OS window pixel coordinates
			var window_pt: Vector2 = xform * global_pt
			window_poly.append(window_pt)
		
		if include_speech and speech_label:
			var label_rect: Rect2 = speech_label.get_global_rect()
			var label_pts := PackedVector2Array([
				xform * label_rect.position,
				xform * Vector2(label_rect.end.x, label_rect.position.y),
				xform * label_rect.end,
				xform * Vector2(label_rect.position.x, label_rect.end.y)
			])
			var all_pts := PackedVector2Array()
			all_pts.append_array(window_poly)
			all_pts.append_array(label_pts)
			var combined_poly: PackedVector2Array = Geometry2D.convex_hull(all_pts)
			DisplayServer.window_set_mouse_passthrough(combined_poly)
		else:
			DisplayServer.window_set_mouse_passthrough(window_poly)
	else:
		# Empty array disables passthrough (whole window accepts clicks)
		DisplayServer.window_set_mouse_passthrough([])

func apply_transparency(transparent: bool) -> void:
	# Update viewport background
	get_viewport().transparent_bg = transparent
	get_tree().root.transparent_bg = transparent
	
	# Update window flags
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, transparent)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, transparent)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, transparent)
	
	# Toggle UI visibility in transparent vs windowed mode
	$UI.visible = !transparent

	# Update mouse passthrough
	if transparent:
		var has_speech: bool = speech_label != null and speech_label.modulate.a > 0.0
		# Defer boundary update to ensure window size & transforms have settled
		update_click_boundary.call_deferred(has_speech)
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
	show_cheer_message(messages.pick_random())

func show_cheer_message(text: String) -> void:
	speech_label.text = text
	
	if active_tween and active_tween.is_running():
		active_tween.kill()

	if is_transparent:
		update_click_boundary(true)

	active_tween = create_tween()
	active_tween.tween_property(speech_label, "modulate:a", 1.0, 0.3)
	active_tween.tween_interval(3.0)
	active_tween.tween_property(speech_label, "modulate:a", 0.0, 0.5)
	active_tween.tween_callback(func():
		if is_transparent:
			update_click_boundary(false)
	)
