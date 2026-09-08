extends Node2D

var file_path = ""
var select_tiles = {}

func render():
	LD.selected = Vector2i(-1, -1)
	for c in $Grid.get_children(): c.queue_free()
	$UI/Width.value = LD.width
	$UI/Height.value = LD.height
	for y in LD.height:
		for x in LD.width:
			var tile = LD.level[Vector2i(x, y)]
			$Grid.add_child(tile)
			tile.scale = (C.grid_size / C.sprite_size) * Vector2(1, 1)
			tile.global_position = Vector2(x * C.grid_size, y * C.grid_size)
			var stile = preload("res://scenes/select_tile.tscn").instantiate()
			stile.x = x
			stile.y = y
			select_tiles[Vector2i(x, y)] = stile
			stile.connect("click", on_click)
			stile.scale = (C.grid_size / C.sprite_size) * Vector2(1, 1)
			stile.z_index = 10
			stile.global_position = Vector2(x * C.grid_size, y * C.grid_size)
			$Grid.add_child(stile)
	if LD.level.has(LD.goal): LD.level[LD.goal].set_goal()
	for t in LD.tips:
		LD.level[t].set_tip(LD.tips[t])

func _ready():
	LD.load_file("res://1-1.mxw")
	render()


func _on_save_pressed() -> void:
	if file_path == "":
		$SaveFile.popup_file_dialog()
	else:
		LD.save_to_file(file_path)

func _on_save_as_pressed() -> void:
	$SaveFile.popup_file_dialog()

func _on_open_pressed() -> void:
	$OpenFile.popup_file_dialog()

func _on_save_file_file_selected(path: String) -> void:
	file_path = path
	LD.save_to_file(path)

func _on_open_file_file_selected(path: String) -> void:
	file_path = path
	LD.load_file(path)
	render()

func _input(event):
	#print(event)
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE and LD.menu:
			$UI/Menu.cancel()
		if event.keycode == KEY_Q:
			_on_cw_rot_pressed()
		if event.keycode == KEY_E:
			_on_ccw_rot_pressed()
		if event.keycode == KEY_S and event.ctrl_pressed and !event.shift_pressed:
			_on_save_pressed()
		if event.keycode == KEY_S and event.ctrl_pressed and event.shift_pressed:
			_on_save_as_pressed()
		if event.keycode == KEY_O and event.ctrl_pressed:
			_on_open_pressed()

func on_click(x: int, y:int) -> void:
	if LD.menu: return
	#print(x, " ", y)
	LD.selected = Vector2i(x, y)
	var palette = $UI/Palette
	if palette.selected == -1: return
	else:
		var dat = palette.palette[palette.selected].get_child(0)
		LD.level[LD.selected].parse(dat.encode())
		update_tile(LD.selected)

func _process(_delta):
	$UI/EditTile.disabled = LD.selected == Vector2i(-1, -1)
	for c in $UI.get_children():
		if c.name != "Menu":
			c.visible = !LD.menu

func _on_edit_tile_pressed() -> void:
	$UI/Menu.visible = true
	$UI/Menu.load_tile()
	LD.menu = true

func _on_deselect_pressed() -> void:
	LD.selected = Vector2i(-1, -1)

func _on_menu_close_menu() -> void:
	$UI/Menu.visible = false
	update_tile(LD.selected)
	LD.menu = false

func update_tile(pos: Vector2i) -> void:
	LD.level[pos].update_display()
	if LD.goal == pos:
		LD.level[pos].set_goal()
	if LD.tips.has(pos):
		LD.level[pos].set_tip(LD.tips[pos])

func update_size() -> void:
	var w = $UI/Width.value
	var h = $UI/Height.value
	if w < LD.width:
		for x in range(w, LD.width):
			for y in range(LD.height):
				var pos = Vector2i(x, y)
				LD.level[pos].queue_free()
				select_tiles[pos].queue_free()
	elif w > LD.width:
		for x in range(LD.width, w):
			for y in range(LD.height):
				var pos = Vector2i(x, y)
				var tile = preload("res://scenes/tile.tscn").instantiate()
				tile.parse(PackedByteArray([0]))
				LD.level[pos] = tile
				$Grid.add_child(tile)
				tile.scale = (C.grid_size / C.sprite_size) * Vector2(1, 1)
				tile.global_position = Vector2(x * C.grid_size, y * C.grid_size)
				var stile = preload("res://scenes/select_tile.tscn").instantiate()
				stile.x = x
				stile.y = y
				select_tiles[Vector2i(x, y)] = stile
				stile.connect("click", on_click)
				stile.scale = (C.grid_size / C.sprite_size) * Vector2(1, 1)
				stile.z_index = 10
				stile.global_position = Vector2(x * C.grid_size, y * C.grid_size)
				$Grid.add_child(stile)
	LD.width = w
	if h < LD.height:
		for y in range(h, LD.height):
			for x in range(LD.width):
				var pos = Vector2i(x, y)
				LD.level[pos].queue_free()
				select_tiles[pos].queue_free()
	elif h > LD.height:
		for y in range(LD.height, h):
			for x in range(LD.width):
				var pos = Vector2i(x, y)
				var tile = preload("res://scenes/tile.tscn").instantiate()
				tile.parse(PackedByteArray([0]))
				LD.level[pos] = tile
				$Grid.add_child(tile)
				tile.scale = (C.grid_size / C.sprite_size) * Vector2(1, 1)
				tile.global_position = Vector2(x * C.grid_size, y * C.grid_size)
				var stile = preload("res://scenes/select_tile.tscn").instantiate()
				stile.x = x
				stile.y = y
				select_tiles[Vector2i(x, y)] = stile
				stile.connect("click", on_click)
				stile.scale = (C.grid_size / C.sprite_size) * Vector2(1, 1)
				stile.z_index = 10
				stile.global_position = Vector2(x * C.grid_size, y * C.grid_size)
				$Grid.add_child(stile)
	LD.height = h
	return

func _on_cw_rot_pressed() -> void:
	if LD.selected == Vector2i(-1, -1): return
	LD.level[LD.selected].rotate_tile(false)
	update_tile(LD.selected)

func _on_ccw_rot_pressed() -> void:
	if LD.selected == Vector2i(-1, -1): return
	LD.level[LD.selected].rotate_tile(true)
	update_tile(LD.selected)
