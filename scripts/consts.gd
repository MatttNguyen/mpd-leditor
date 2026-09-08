extends Node

const sprite_size = 35.0
const grid_size = 200.0

enum T {NEUTRAL=0, HOT=1, COLD=2, GREEN=3} # Neutral, Hot, Cold, Green
enum E {STICKY=0, CONDUCT=1, INSULATE=2} # Sticky, Conducting, Insulating
enum TT {EMPTY=0, PLAYER_START=1, BLOCK=2, LEVEL=3, PISTON=4, MULTI=5}

const U = Vector2i.UP
const D = Vector2i.DOWN
const L = Vector2i.LEFT
const R = Vector2i.RIGHT
const Dirs = [U, R, D, L]

const colors_base = {
	T.NEUTRAL: Color("e5e5e5"),
	T.HOT: Color("ffb5a6"),
	T.COLD: Color("a6d2ff"),
	T.GREEN: Color("acf29d")
}

const colors_outline = {
	T.NEUTRAL: Color("b2b2b2"),
	T.HOT: Color("f26549"),
	T.COLD: Color("499df2"),
	T.GREEN: Color("55cc3d")
}
