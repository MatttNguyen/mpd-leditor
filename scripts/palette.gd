extends Control

var length = 0
var palette = []
var selected = -1

@onready var container = $Panel/MarginContainer/ScrollContainer/HBoxContainer

func load_file() -> void:
	var dat = FileAccess.get_file_as_bytes("user://palette.pmxw")
	if dat.size() == 0:
		# Write empty palette
		var file = FileAccess.open("user://palette.pmxw", FileAccess.WRITE)
		file.store_buffer([0])
		file.close()
		return
	length = dat[0]
	var pointer = 1
	var pointer2 = 1
	for x in range(length):
		var ptile = preload("res://scenes/palette_tile.tscn").instantiate()
		var tile = ptile.get_child(0)
		var stile = ptile.get_child(1)
		pointer2 = pointer + LD.get_level(dat.slice(pointer))
		tile.parse(dat.slice(pointer, pointer2))
		stile.x = x
		stile.palette = true
		stile.connect("click_palette", click)
		stile.z_index = 11
		ptile.custom_minimum_size = Vector2(132, 132)
		palette.append(ptile)
		container.add_child(ptile)
		pointer = pointer2

func save_file() -> void:
	var out = PackedByteArray()
	out.append(length)
	for ptile in palette:
		var tile = ptile.get_child(0)
		out.append_array(tile.encode())
	var file = FileAccess.open("user://palette.pmxw", FileAccess.WRITE)
	file.store_buffer(out)
	file.close()

func add_tile() -> void:
	if LD.selected == Vector2i(-1, -1): return
	var ptile = preload("res://scenes/palette_tile.tscn").instantiate()
	var tile = ptile.get_child(0)
	var stile = ptile.get_child(1)
	tile.parse(LD.level[LD.selected].encode())
	stile.x = length
	stile.palette = true
	stile.connect("click_palette", click)
	stile.z_index = 11
	ptile.custom_minimum_size = Vector2(132, 132)
	palette.append(ptile)
	container.add_child(ptile)
	length += 1
	save_file()

func remove_tile() -> void:
	if selected == -1: return
	var ptile = palette[selected]
	palette.erase(ptile)
	length -= 1
	if selected == length: selected -= 1
	if selected != 1: palette[selected].get_child(1).selected = true
	ptile.queue_free()
	for x in range(length):
		palette[x].get_child(1).x = x
	save_file()

func _ready():
	load_file()

func _process(_delta):
	$Panel/Remove.disabled = selected == -1

func click(x: int):
	#print(selected, " ", x)
	if selected != -1: palette[selected].get_child(1).selected = false
	if selected == x:
		selected = -1
		return
	selected = x
	#print(palette[selected].get_child(1))
	palette[selected].get_child(1).selected = true
