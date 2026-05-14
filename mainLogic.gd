extends Node2D

#figures
var FIGURES = [
	{"name": "I", "color": Color("0087c5ff"), "shape": [[0,0], [1,0], [2,0], [3,0]]},
	{"name": "O", "color": Color("#E8C00E"), "shape": [[0,0], [0,1], [1,0], [1,1]]},
	{"name": "T", "color": Color("#8C10C2"), "shape": [[1,0], [0,1], [1,1], [2,1]]},
	{"name": "Z", "color": Color("#B31515"), "shape": [[0,0], [1,0], [1,1], [2,1]]},
	{"name": "S", "color": Color("11c709ff"), "shape": [[0,1], [1,0], [1,1], [2,0]]},
	{"name": "L", "color": Color("dd4807ff"), "shape": [[0,0], [1,0], [2,0], [0,1]]},
	{"name": "J", "color": Color("#0030DB"), "shape": [[0,0], [1,0], [2,0], [2,1]]}
]

#bools
var FAST_FALL = false
var PAUSE = false

#info
var F_WIDTH = 10
var F_HEIGHT = 20
var CELL_SIZE = 32
var FIELD = []
var COLOR_FIELD = []
var SCORE = 0
var LEVEL = 1
var TIME = 0.7
var NEXT_LVL_SCORE = 5000

#textures
var BRICK_TEXTURE = preload("res://sourceFiles/blank_brick.png")
var BLANK_COLOR = Color(0,0,0,0)

#actives
var ACTIVE_SHAPE = null
var ACTIVE_POS = null
var ACTIVE_COLOR = BLANK_COLOR
var NEXT_COLOR = BLANK_COLOR
var NEXT_SHAPE = null

@onready var background = $Background
@onready var field_background = $"Field Background"
@onready var score_background = $"Score Background"
@onready var blocks_container = $"Field Background/Blocks Container"
@onready var timer = $FallTimer
@onready var score_label = $"Score Background/ScoreLabel"
@onready var next_piece_background = $"Next Piece Background"
@onready var preview_container = $"Next Piece Background/Preview Container"
@onready var game_over_screen = $"Game Over Screen"
@onready var pause_screen = $"Pause Screen"
@onready var level_background = $"Level Background"
@onready var level_label = $"Level Background/LevelLabel"

func _ready():
	var windowSize = get_viewport_rect().size
	
	var fieldSize = Vector2(F_WIDTH*CELL_SIZE, F_HEIGHT*CELL_SIZE)
	var scoreSize = Vector2(160, 64)
	var npSize = Vector2(160, 105)
	var lvlSize = Vector2(160, 64)
	
	var f_start_x = (windowSize.x - fieldSize.x)/2
	var f_start_y = (windowSize.y - fieldSize.y)/2
	
	var fieldPosition = Vector2(f_start_x, f_start_y)
	var scorePosition = Vector2(f_start_x-182, f_start_y+50)
	var npPosition = Vector2(f_start_x-182, f_start_y+150)
	var lvlPosition = Vector2(f_start_x-182, f_start_y+300)
	
	#setting field
	set_background(windowSize)
	set_field_background(fieldSize, fieldPosition)
	set_score_background(scoreSize, scorePosition)
	set_np_background(npSize, npPosition)
	set_level_background(lvlSize, lvlPosition)
	blocks_container.position = Vector2(16, 16)
	field_init()
	game_over_init()
	score_update(0)
	level_label.text = "LVL: %d"%LEVEL
	
	#the game
	var f1 = choose_figure()
	var f2 = choose_figure()
	ACTIVE_SHAPE = f1.shape.duplicate(true)
	ACTIVE_COLOR = f1.color
	NEXT_SHAPE = f2.shape.duplicate(true)
	NEXT_COLOR = f2.color
	ACTIVE_POS = Vector2(4,0)
	update_preview()
	field_render()
	timer.wait_time = TIME
	timer.timeout.connect(_on_fall_timer_timeout)

#backgrounds
func set_background(windowSize):
	background.color = Color("#003153")
	background.size = windowSize
	background.position = Vector2(0,0)
func set_field_background(fieldSize, pos):
	field_background.color = Color("#0a1428")
	field_background.size = fieldSize
	field_background.position = pos
func set_score_background(size, pos):
	score_background.color = Color("#0a1428")
	score_background.size = size
	score_background.position = pos
func set_np_background(size, pos):
	next_piece_background.color = Color("#0a1428")
	next_piece_background.size = size
	next_piece_background.position = pos
func set_level_background(size, pos):
	level_background.color = Color("#0a1428")
	level_background.size = size
	level_background.position = pos

#init
func field_init():
	FIELD = []
	COLOR_FIELD = []
	for y in range(F_HEIGHT):
		FIELD.append([])
		COLOR_FIELD.append([])
		for x in range(F_WIDTH):
			FIELD[y].append(0)
			COLOR_FIELD[y].append(BLANK_COLOR)
func field_render():
	for child in blocks_container.get_children():
		child.queue_free()
	
	for y in range(F_HEIGHT):
		for x in range(F_WIDTH):
			if FIELD[y][x] != 0:
				var sprite = Sprite2D.new()
				sprite.texture = BRICK_TEXTURE
				sprite.position = Vector2(x*CELL_SIZE, y*CELL_SIZE)
				sprite.modulate = COLOR_FIELD[y][x]
				blocks_container.add_child(sprite)
	
	if ACTIVE_SHAPE != null and ACTIVE_POS != null:
		for c in ACTIVE_SHAPE:
			var sprite = Sprite2D.new()
			sprite.texture = BRICK_TEXTURE
			var x = (ACTIVE_POS.x+c[0]) * CELL_SIZE
			var y = (ACTIVE_POS.y+c[1]) * CELL_SIZE
			sprite.position = Vector2(x,y)
			sprite.modulate = ACTIVE_COLOR
			blocks_container.add_child(sprite)
func score_update(ds):
	SCORE += ds
	score_label.text = "%06d"%SCORE
func lvl_update():
	LEVEL += 1
	TIME = max(0.1, TIME*0.9)
	timer.wait_time = TIME
	level_label.text = "LVL: %d"%LEVEL
func update_preview():
	for child in preview_container.get_children():
		child.queue_free()
	
	if NEXT_SHAPE != null:
		for c in NEXT_SHAPE:
			var nsprite = Sprite2D.new()
			nsprite.texture = BRICK_TEXTURE
			var x = (1.5+c[0])*CELL_SIZE
			var y = (1+c[1])*CELL_SIZE
			nsprite.position = Vector2(x,y)
			nsprite.modulate = NEXT_COLOR
			preview_container.add_child(nsprite)
func game_over_init():
	var overlay = game_over_screen.get_node("Overlay")
	overlay.color = Color(0,0,0,0.8)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var strip = game_over_screen.get_node("Strip")
	strip.color = Color("#1a1a1a")
	strip.custom_minimum_size.y = 150
	strip.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	strip.anchor_right = 1.0
	strip.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var labelgameover = game_over_screen.get_node("Strip/Label Game Over")
	labelgameover.text = "Game Over!"
	labelgameover.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var container = game_over_screen.get_node("VBoxContainer")
	container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	container.grow_vertical = Control.GROW_DIRECTION_BOTH
	container.position.y += 140
	
	var labelscore = game_over_screen.get_node("VBoxContainer/Label Score")
	labelscore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var button = game_over_screen.get_node("VBoxContainer/Button Restart")
	button.text = "Restart"
	button.custom_minimum_size = Vector2(150,40)
	button.pressed.connect(_on_restart_pressed)
	
	var button_mm = game_over_screen.get_node("VBoxContainer/Button Main Menu")
	button_mm.text = "Quit"
	button_mm.custom_minimum_size = Vector2(150,40)
	button_mm.pressed.connect(_on_main_menu_pressed)
	
	game_over_screen.hide()
func check_lvl():
	if SCORE > NEXT_LVL_SCORE:
		lvl_update()
		NEXT_LVL_SCORE += 5000

#movement
func move_piece_down():
	if can_move(ACTIVE_SHAPE, ACTIVE_POS, 0, 1):
		ACTIVE_POS.y += 1
		field_render()
	else:
		fix_piece()
func move_piece_side(dx):
	if can_move(ACTIVE_SHAPE, ACTIVE_POS, dx, 0):
		ACTIVE_POS.x += dx
		field_render()
func rotate_piece(side):
	var r_shape = []
	
	if side == "right":
		for s in ACTIVE_SHAPE:
			r_shape.append([s[1], -s[0]])
	else:
		for s in ACTIVE_SHAPE:
			r_shape.append([-s[1], s[0]])
	
	var offsets = [
		Vector2(0,0),
		Vector2(-1,0),
		Vector2(1,0),
		Vector2(0,-1),
		Vector2(0,1)
	]
	
	for of in offsets:
		var new_pos = ACTIVE_POS + of
		if can_move(r_shape, new_pos, 0, 0):
			ACTIVE_SHAPE = r_shape
			ACTIVE_POS = new_pos
			field_render()
			return
func can_move(shape, pos, dx, dy):
	for block in shape:
		var new_x = pos.x + block[0] + dx
		var new_y = pos.y + block[1] + dy
		
		if new_x < 0 or new_x >= F_WIDTH or new_y >= F_HEIGHT:
			return false
		if new_y >= 0 and FIELD[new_y][new_x] != 0:
			return false
	return true
func fix_piece():
	for c in ACTIVE_SHAPE:
		var fx = ACTIVE_POS.x + c[0]
		var fy = ACTIVE_POS.y + c[1]
		if fy >= 0:
			FIELD[fy][fx] = 1
			COLOR_FIELD[fy][fx] = ACTIVE_COLOR
	var lines_count = clear_lines()
	if lines_count == 1:
		score_update(200);
	elif lines_count == 2:
		score_update(400)
	elif lines_count == 3:
		score_update(600)
	elif lines_count == 4:
		score_update(1200)
	else:
		score_update(10)
	ACTIVE_POS = Vector2(4,0)
	ACTIVE_SHAPE = NEXT_SHAPE
	ACTIVE_COLOR = NEXT_COLOR
	var f_next = choose_figure()
	NEXT_SHAPE = f_next.shape.duplicate(true)
	NEXT_COLOR = f_next.color
	update_preview()
	check_game_over()
	check_lvl()
	field_render()
func clear_lines():
	var cleared = 0
	var yc = F_HEIGHT-1
	while yc >= 0:
		var full = true
		for x in range(F_WIDTH):
			if FIELD[yc][x] == 0:
				full = false
				break
		if full:
			for x in range(F_WIDTH):
				FIELD[yc][x] = 0
			for row in range(yc, 0, -1):
				for x in range(F_WIDTH):
					FIELD[row][x] = FIELD[row-1][x]
					COLOR_FIELD[row][x] = COLOR_FIELD[row-1][x]
			for x in range(F_WIDTH):
				FIELD[0][x] = 0
				COLOR_FIELD[0][x] = BLANK_COLOR
			cleared += 1
		else:
			yc -= 1
	if cleared > 0:
		return cleared
	return 0
func hard_drop():
	while (can_move(ACTIVE_SHAPE, ACTIVE_POS, 0, 1)):
		ACTIVE_POS.y += 1
	fix_piece()
func _on_fall_timer_timeout():
	move_piece_down()

#figures
func choose_figure():
	var index = randi() % FIGURES.size()
	return FIGURES[index]

#game over logic
func check_game_over():
	if (!can_move(ACTIVE_SHAPE, ACTIVE_POS, 0, 0)):
		show_game_over()
func show_game_over():
	timer.stop()
	set_process(false)
	
	SaveScript.save_score(SCORE)
	
	var labelscore = game_over_screen.get_node("VBoxContainer/Label Score")
	labelscore.text = "Final score: %06d\nBest score: %06d" % [SCORE, SaveScript.high_score]
	game_over_screen.show()

#input
func _process(_delta):
	if Input.is_action_just_pressed("ui_left"):
		move_piece_side(-1)
	elif Input.is_action_just_pressed("ui_right"):
		move_piece_side(1)
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_piece("left")
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_piece("right")
	elif Input.is_action_just_pressed("ui_up"):
		hard_drop()
	
	if Input.is_action_pressed("ui_down"):
		if not FAST_FALL:
			FAST_FALL = true
			timer.wait_time = 0.05
	else:
		if FAST_FALL:
			FAST_FALL = false
			timer.wait_time = TIME
	
func _on_restart_pressed():
	get_tree().reload_current_scene()
func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
