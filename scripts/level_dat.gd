extends Node

var width: int
var height: int

var goal = Vector2i(-1, -1)
var tips = {}

var level = {}
var stiles = {}
var selected = Vector2i(-1, -1)

var menu: bool

func parse(dat: PackedByteArray) -> void:
	goal = Vector2i(-1, -1)
	tips = {}
	level = {}
	width = dat[0]
	height = dat[1]
	#print(width, " ", height)
	var pointer = 2
	var pointer2 = 2
	for y in range(height):
		for x in range(width):
			#print(x, " ", y)
			var tile = preload("res://scenes/tile.tscn").instantiate()
			pointer2 = pointer + get_level(dat.slice(pointer))
			tile.parse(dat.slice(pointer, pointer2))
			level[Vector2i(x, y)] = tile
			pointer = pointer2
	#print(dat.slice(pointer - 5))
	var type = dat[pointer]
	while type != 0:
		if type == 1:
			goal = Vector2i(dat[pointer + 1], dat[pointer + 2])
			pointer += 3
		if type == 2:
			var pos = Vector2i(dat[pointer + 1], dat[pointer + 2])
			pointer += 3
			var id = ""
			while dat[pointer] != 0:
				id += String.chr(dat[pointer])
				pointer += 1
			tips[pos] = id
			pointer += 1
		type = dat[pointer]

func get_level(dat: PackedByteArray) -> int:
	#print(dat.slice(0, 10))
	var type = dat[0]
	if type == 0 || type == 1:
		return 1
	if type == 2:
		return 3
	if type == 3:
		var pointer = 2
		while dat[pointer] != 0: pointer += 1
		return pointer + 7
	if type == 4:
		if dat[1] & 1 == 0: return 6 + get_level(dat.slice(6))
		else: return 6
	else:
		return 5

func encode() -> PackedByteArray:
	var out = PackedByteArray()
	out.append(width)
	out.append(height)
	for y in range(height):
		for x in range(width):
			out.append_array(level[Vector2i(x, y)].encode())
	if goal != Vector2i(-1, -1):
		out.append(1)
		out.append(goal.x)
		out.append(goal.y)
	for t in tips:
		out.append(2)
		out.append(t.x)
		out.append(t.y)
		for c in tips[t]:
			out.append(ord(c))
	out.append(0)
	return out

func load_file(path: String) -> void:
	parse(FileAccess.get_file_as_bytes(path))

func save_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(encode())
	file.close()
