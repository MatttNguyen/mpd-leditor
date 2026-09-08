extends Node2D

@export var type: C.TT
@export var level_shortcut: bool
@export var level_ID: String
@export var piston_extended: bool
@export var piston_dir: Vector2i
@export var piston_priority: int
@export var multi_value: int

var inner_tile

func parse(dat: PackedByteArray) -> void:
	#print(dat)
	type = dat[0] as C.TT
	if type == 0 or type == 1: return
	if type == 2:
		$Main.parse(dat)
	if type == 3:
		level_shortcut = dat[1]
		var pointer = 2
		level_ID = ""
		while dat[pointer] != 0:
			level_ID += String.chr(dat[pointer])
			pointer += 1
		$Main.parse(dat.slice(pointer + 1, pointer + 4))
		$Level_After.parse(dat.slice(pointer + 4, pointer + 7))
	if type == 4:
		var AA = dat[1]
		piston_extended = (AA & 0b1) != 0
		piston_dir = C.Dirs[(AA & 0b110) >> 1]
		$Main.parse(dat.slice(2, 5))
		piston_priority = dat[5]
		if !piston_extended:
			inner_tile = preload("res://scenes/tile.tscn").instantiate()
			inner_tile.parse(dat.slice(6))
			add_child(inner_tile)
			inner_tile.visible = false
	if type == 5:
		$Main.parse(PackedByteArray([2, dat[1], dat[2]]))
		multi_value = dat[4] * 0x100 + dat[3]
		#print(dat[3], " ", dat[4], " ", multi_value)

func encode() -> PackedByteArray:
	var out = PackedByteArray()
	out.append(type)
	if type == 2:
		out.append_array($Main.encode().slice(1))
	if type == 3:
		out.append(int(level_shortcut))
		for c in level_ID:
			out.append(ord(c))
		out.append(0)
		out.append_array($Main.encode())
		out.append_array($Level_After.encode())
	if type == 4:
		out.append(int(piston_extended) + (C.Dirs.find(piston_dir) << 1))
		out.append_array($Main.encode())
		out.append(piston_priority)
		if !piston_extended: out.append_array(inner_tile.encode())
	if type == 5:
		out.append_array($Main.encode().slice(1))
		out.append(multi_value & 0x00ff)
		out.append(multi_value & 0xff00)
	#print(out)
	return out

func update_display() -> void:
	$Main.visible = false
	$Level_After.visible = false
	$Sprite.visible = false
	$Label.visible = false
	$Sprite2.visible = false
	$Label2.visible = false
	$Sprite.modulate = Color(1, 1, 1)
	if type == 0:
		$Sprite.texture = load("res://assets/empty.png")
		$Sprite.modulate = C.colors_outline[C.T.NEUTRAL]
		$Sprite.visible = true
	if type == 1:
		$Sprite.texture = load("res://assets/player_start.png")
		$Sprite.modulate = C.colors_outline[C.T.NEUTRAL]
		$Sprite.visible = true
	if type == 2:
		$Main.visible = true
		$Main.update_visual()
	if type == 3:
		$Main.visible = true
		$Main.update_visual()
		#$Level_After.update_visual()
		$Label.text = level_ID
		$Label.visible = true
	if type == 4:
		$Main.visible = true
		$Main.update_visual()
		if piston_extended:
			$Sprite.texture = load("res://assets/piston_extended.png")
		else:
			$Sprite.texture = load("res://assets/piston_retracted.png")
		$Sprite.modulate = C.colors_outline[$Main.temperature]
		$Sprite.visible = true
		$Sprite.look_at(Vector2(piston_dir).rotated(PI/2) + $Sprite.global_position)
		$Label.visible = true
		$Label.text = "#" + str(piston_priority + 1)
	if type == 5:
		$Main.visible = true
		$Main.update_visual()
		$Label.visible = true
		$Label.text = "*" + str(multi_value)

func _ready():
	$Main.z_index = 0
	$Sprite.z_index = 4
	$Label.z_index = 6
	$Sprite2.z_index = 5
	update_display()

func set_goal():
	$Sprite2.visible = true
	$Sprite2.texture = load("res://assets/goal.png")
	$Sprite2.modulate = C.colors_outline[C.T.COLD]

func set_tip(_id: String):
	$Sprite2.visible = true
	$Sprite2.texture = load("res://assets/tip.png")
	$Sprite2.modulate = C.colors_outline[C.T.COLD]
	#$Label2.visible = true
	#$Label2.text = id

func rotate_tile(ccw: bool) -> void:
	if type != 0 and type != 1: $Main.rotate_block(ccw)
	if type == 3: $Level_After.rotate_block(ccw)
	if type == 4:
		if !piston_extended: inner_tile.rotate_tile(ccw)
		piston_dir = Vector2i(-piston_dir.y, piston_dir.x)
		if ccw: piston_dir = -piston_dir
