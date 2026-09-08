extends Node2D

signal click(x: int, y: int)
signal click_palette(x: int)

var x: int
var y: int
var palette = false
var selected = false

func _on_click() -> void:
	if !Input.is_key_pressed(KEY_SPACE):
		#print(x)
		if !palette: click.emit(x, y)
		else: click_palette.emit(x)

func _process(_delta):
	$Sprite2D.visible = (!palette and LD.selected == Vector2i(x, y)) or (palette and selected)
	return
