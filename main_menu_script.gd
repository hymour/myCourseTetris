extends Node

@onready var background = $Background
@onready var logo = $Background/CenterContainer/VBoxContainer/Logo
@onready var play_b = $Background/CenterContainer/VBoxContainer/PlayButton
@onready var quit_b = $Background/CenterContainer/VBoxContainer/QuitButton
@onready var high_s = $Background/CenterContainer/VBoxContainer/HighScore

var LOGO_TEXTURE = preload("res://sourceFiles/logo.png")

func _ready():
	var windowSize = get_viewport().size
	
	set_background(windowSize)
	set_logo()
	set_buttons()
	high_s.text = "Best Score: %06d" % SaveScript.high_score
	high_s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func set_background(windowSize):
	background.color = Color("#003153")
	background.size = windowSize
	background.position = Vector2(0,0)
func set_logo():
	logo.texture = LOGO_TEXTURE
	logo.custom_minimum_size = Vector2(400,200)
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
func set_buttons():
	play_b.text = "Play"
	quit_b.text = "Quit"
	play_b.custom_minimum_size = Vector2(250,60)
	quit_b.custom_minimum_size = Vector2(250,60)
	play_b.pressed.connect(_on_play_button_pressed)
	quit_b.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Game.tscn")
func _on_quit_button_pressed():
	get_tree().quit()
