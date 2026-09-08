extends Camera2D

var zoom_target: Vector2
var zoom_factor = 0.1

var drag_mouse = Vector2.ZERO
var drag_cam = Vector2.ZERO
var is_drag = false

func _ready():
	zoom_target = zoom

func _process(_delta):
	if LD.menu: return
	if Input.is_action_just_pressed("zoom_in"):
		zoom_target *= 1 + zoom_factor
	if Input.is_action_just_pressed("zoom_out"):
		zoom_target *= 1 - zoom_factor
	zoom = zoom.slerp(zoom_target, 1)
	
	if !is_drag and Input.is_action_just_pressed("pan"):
		drag_mouse = get_viewport().get_mouse_position()
		drag_cam = position
		is_drag = true
	if is_drag and (Input.is_action_just_released("pan") or !Input.is_key_pressed(KEY_SPACE)):
		is_drag = false
	if is_drag:
		var mouse_move = get_viewport().get_mouse_position() - drag_mouse
		position = drag_cam - mouse_move / zoom.x
