extends Node2D

class_name Block

@export var temperature: C.T
@export var edges: Dictionary[Vector2i, C.E] = {
	C.U: C.E.STICKY,
	C.D: C.E.STICKY,
	C.L: C.E.STICKY,
	C.R: C.E.STICKY
}
@export var fixed: bool
@export var glass: bool

@onready var edges_obj = {
	C.U: $Edge_Up,
	C.D: $Edge_Down,
	C.L: $Edge_Left,
	C.R: $Edge_Right
}

func update_visual() -> void:
	if glass:
		$Base.texture = load("res://assets/glass.png")
	else:
		$Base.texture = load("res://assets/base.png")
	$Base.modulate = C.colors_base[temperature]
	$Fixed.texture = load("res://assets/fixed.png")
	$Fixed.modulate = C.colors_outline[temperature]
	$Fixed.visible = true
	if not fixed: $Fixed.visible = false
	for d in C.Dirs:
		var obj = edges_obj[d]
		var edge = edges[d]
		if edge == C.E.STICKY:
			obj.texture = load("res://assets/edge_sticky.png")
		elif edge == C.E.CONDUCT:
			obj.texture = load("res://assets/edge_conduct.png")
		else:
			obj.texture = load("res://assets/edge_insulate.png")
		if edge != C.E.INSULATE:
			obj.modulate = C.colors_outline[temperature]
			obj.z_index = 2
		else:
			obj.modulate = Color(1, 1, 1)
			obj.z_index = 3

func _ready():
	$Edge_Up.rotation_degrees = 0
	$Edge_Down.rotation_degrees = 180
	$Edge_Left.rotation_degrees = 270
	$Edge_Right.rotation_degrees = 90
	edges_obj[C.U] = $Edge_Up
	edges_obj[C.D] = $Edge_Down
	edges_obj[C.L] = $Edge_Left
	edges_obj[C.R] = $Edge_Right
	$Base.z_index = 0
	$Fixed.z_index = 1
	# update_visual()

func parse(dat: PackedByteArray) -> void:
	var XX = dat[1]
	fixed = (XX & 0b0001) >> 0 != 0
	glass = (XX & 0b0010) >> 1 == 0
	temperature = ((XX & 0b1100) >> 2) as C.T
	var YY = dat[2]
	edges[C.U] = ((YY & 0b11000000) >> 6) as C.E
	edges[C.R] = ((YY & 0b00110000) >> 4) as C.E
	edges[C.D] = ((YY & 0b00001100) >> 2) as C.E
	edges[C.L] = ((YY & 0b00000011) >> 0) as C.E

func encode() -> PackedByteArray:
	var XX = int(fixed) + (int(!glass) << 1) + (temperature << 2)
	var YY = (edges[C.U] << 6) + (edges[C.R] << 4) + (edges[C.D] << 2) + edges[C.L]
	return PackedByteArray([2, XX, YY])

func rotate_block(ccw: bool) -> void:
	var new_edges: Dictionary[Vector2i, C.E] = {}
	for x in edges:
		var nx = Vector2i(x.y, -x.x)
		if ccw: nx = -nx
		new_edges[nx] = edges[x] as C.E
	edges = new_edges
