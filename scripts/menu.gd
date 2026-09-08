extends Control

signal close_menu()

var dat: Array[PackedByteArray]
var curr_index: int

func load_tile() -> void:
	dat.clear()
	var data = LD.level[LD.selected].encode()
	while data:
		#print(data, " ", dat)
		if data[0] == 4:
			dat.append(data.slice(0, 6))
			data = data.slice(6)
		else:
			dat.append(data.duplicate())
			data.clear()
	curr_index = 0
	update_from_dat()

func update_from_dat() -> void:
	var data = dat[curr_index]
	#print(data)
	var type = data[0]
	$Panel/Type.selected = type
	#print(curr_index)
	if type == 4:
		data.append(0)
	var tile = $Panel/Tile
	tile.parse(data)
	tile.update_display()
	tile.scale = (C.grid_size / C.sprite_size) * Vector2(1, 1)
	for child in $Panel.get_children():
		child.visible = false
	$Panel/Tile.visible = true
	$Panel/Type.visible = true
	$Panel/Save.visible = true
	$Panel/Cancel.visible = true
	$Panel/EmptyControl.visible = true
	if type == 0 or type == 1:
		# Default
		$Panel/BlockControl/EdgeUp.selected = 0
		$Panel/BlockControl/EdgeRight.selected = 0
		$Panel/BlockControl/EdgeDown.selected = 0
		$Panel/BlockControl/EdgeLeft.selected = 0
		$Panel/BlockControl/Fixed.button_pressed = false
		$Panel/BlockControl/Glass.button_pressed = false
		$Panel/BlockControl/Temperature.selected = 0
		$Panel/LevelControl/LevelShortcut.button_pressed = false
		$Panel/LevelControl/LevelID.text = ""
		$Panel/LevelControl/BeforeAfter.button_pressed = false
		$Panel/PistonControl/Direction.selected = 0
		$Panel/PistonControl/Extended.button_pressed = false
		$Panel/PistonControl/Priority.value = 1
		$Panel/MultiControl/Value.value = 1
	if type == 2:
		update_block_control()
	if type == 3:
		update_block_control()
		$Panel/LevelControl.visible = true
		$Panel/LevelControl/LevelShortcut.button_pressed = data[1]
		$Panel/LevelControl/LevelID.text = tile.level_ID
		$Panel/LevelControl/BeforeAfter.button_pressed = false
	if type == 4:
		update_block_control()
		$Panel/PistonControl.visible = true
		$Panel/PistonControl/Extended.button_pressed = tile.piston_extended
		$Panel/PistonControl/Direction.selected = C.Dirs.find(tile.piston_dir)
		$Panel/PistonControl/Priority.value = tile.piston_priority + 1
	if type == 5:
		update_block_control()
		$Panel/MultiControl.visible = true
		$Panel/MultiControl/Value.value = tile.multi_value
	if curr_index > 0:
		$Panel/PrevLayer.visible = true
	if curr_index < dat.size() - 1:
		$Panel/NextLayer.visible = true
	
	$Panel/EmptyControl/Goal.button_pressed = false
	$Panel/EmptyControl/Tip.button_pressed = false
	$Panel/EmptyControl/TipID.text = ""
	if LD.goal == LD.selected:
		tile.set_goal()
		$Panel/EmptyControl/Goal.button_pressed = true
	if LD.tips.has(LD.selected):
		$Panel/EmptyControl/Tip.button_pressed = true
		tile.set_tip(LD.tips[LD.selected])
		$Panel/EmptyControl/TipID.text = LD.tips[LD.selected]

func update_block_control() -> void:
	$Panel/BlockControl.visible = true
	var block = $Panel/Tile/Main
	#print(block.edges)
	$Panel/BlockControl/Fixed.button_pressed = block.fixed
	$Panel/BlockControl/Glass.button_pressed = block.glass
	$Panel/BlockControl/Temperature.selected = block.temperature
	$Panel/BlockControl/EdgeUp.selected    = block.edges[C.U]
	$Panel/BlockControl/EdgeLeft.selected  = block.edges[C.L]
	$Panel/BlockControl/EdgeDown.selected  = block.edges[C.D]
	$Panel/BlockControl/EdgeRight.selected = block.edges[C.R]

func update_to_dat() -> void:
	var tile = $Panel/Tile
	tile.type = $Panel/Type.selected as C.TT
	var type = tile.type
	#print(type)
	if type != 4 or (type == 4 and $Panel/PistonControl/Extended.button_pressed):
		while curr_index != dat.size() - 1:
			dat.remove_at(dat.size() - 1)
	for child in $Panel.get_children():
		child.visible = false
	$Panel/Tile.visible = true
	$Panel/Type.visible = true
	$Panel/Save.visible = true
	$Panel/Cancel.visible = true
	$Panel/EmptyControl.visible = true
	if type == 2:
		update_block()
	if type == 3:
		update_block()
		$Panel/LevelControl.visible = true
		tile.level_shortcut = $Panel/LevelControl/LevelShortcut.button_pressed
		tile.level_ID = $Panel/LevelControl/LevelID.text
	if type == 4:
		update_block()
		$Panel/PistonControl.visible = true
		tile.piston_dir = C.Dirs[$Panel/PistonControl/Direction.selected]
		tile.piston_extended = $Panel/PistonControl/Extended.button_pressed
		tile.piston_priority = $Panel/PistonControl/Priority.value - 1
		if !tile.piston_extended:
			tile.inner_tile = preload("res://scenes/tile.tscn").instantiate()
			tile.inner_tile.parse([0])
			tile.add_child(tile.inner_tile)
			tile.inner_tile.visible = false
	if type == 5:
		update_block()
		$Panel/MultiControl.visible = true
		tile.multi_value = int($Panel/MultiControl/Value.value)
	tile.update_display()
	if type == 0 and $Panel/EmptyControl/Goal.button_pressed:
		tile.set_goal()
	if $Panel/EmptyControl/Tip.button_pressed:
		tile.set_tip($Panel/EmptyControl/TipID.text)
	var data = dat[curr_index]
	data = tile.encode()
	if type == 4 and !tile.piston_extended:
		data.remove_at(data.size() - 1)
		dat.append(PackedByteArray([0]))
	
	if type == 3 and $Panel/LevelControl/BeforeAfter.button_pressed:
		var temp = data.slice(-6, -3)
		var temp2 = data.slice(-3)
		data.resize(data.size() - 6)
		data.append_array(temp2)
		data.append_array(temp)
	
	dat[curr_index] = data
	#print(dat)
	if curr_index > 0:
		$Panel/PrevLayer.visible = true
	if curr_index < dat.size() - 1:
		$Panel/NextLayer.visible = true

func update_block() -> void:
	$Panel/BlockControl.visible = true
	var block = $Panel/Tile/Main
	block.fixed = $Panel/BlockControl/Fixed.button_pressed
	block.glass = $Panel/BlockControl/Glass.button_pressed
	block.temperature = $Panel/BlockControl/Temperature.selected as C.T
	block.edges[C.U] = $Panel/BlockControl/EdgeUp.selected as C.E
	block.edges[C.L] = $Panel/BlockControl/EdgeLeft.selected as C.E
	block.edges[C.D] = $Panel/BlockControl/EdgeDown.selected as C.E
	block.edges[C.R] = $Panel/BlockControl/EdgeRight.selected as C.E
	block.update_visual()

func _ready():
	#LD.load_file("m99A.mxw")
	#LD.selected = Vector2i.ZERO
	#load_tile()
	return

func select_signal(_index: int) -> void:
	update_to_dat()

func text_signal(_text: String) -> void:
	update_to_dat()
	
func val_signal(_val: float) -> void:
	update_to_dat()

func before_after() -> void:
	var temp = $Panel/Tile/Main.encode()
	var temp2 = $Panel/Tile/Level_After.encode()
	$Panel/Tile/Main.parse(temp2)
	$Panel/Tile/Level_After.parse(temp)
	$Panel/Tile.update_display()
	update_block_control()

func next_layer() -> void:
	curr_index += 1
	update_from_dat()

func prev_layer() -> void:
	curr_index -= 1
	update_from_dat()

func save_tile() -> void:
	var data = PackedByteArray()
	for d in dat: data.append_array(d)
	LD.level[LD.selected].parse(data)
	if $Panel/EmptyControl/Goal.button_pressed:
		LD.level[LD.goal].update_display()
		if LD.tips.has(LD.goal):
			LD.level[LD.goal].set_tip(LD.tips[LD.goal])
		LD.goal = LD.selected
	if $Panel/EmptyControl/Tip.button_pressed:
		LD.tips[LD.selected] = $Panel/EmptyControl/TipID.text
	if LD.tips.has(LD.selected) and !$Panel/EmptyControl/Tip.button_pressed:
		LD.tips.erase(LD.selected)
	close_menu.emit()

func cancel() -> void:
	close_menu.emit()
