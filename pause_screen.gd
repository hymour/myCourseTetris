extends CanvasLayer

@onready var overlay = $"Overlay"
@onready var container = $"VBoxContainer"
@onready var resume_button = $"VBoxContainer/Button Resume"
@onready var main_menu_button = $"VBoxContainer/Button Main Menu"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.color = Color(0,0,0,0.8)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hide()
	
	container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	container.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	resume_button.text = "Продолжить"
	resume_button.custom_minimum_size = Vector2(180,40)
	resume_button.pressed.connect(_on_resume_pressed)
	
	main_menu_button.text = "Вернуться в главное меню"
	main_menu_button.custom_minimum_size = Vector2(180,40)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			hide_pause()
		else:
			show_pause()

func hide_pause():
	get_tree().paused = false
	hide()

func show_pause():
	get_tree().paused = true
	show()


func _on_resume_pressed():
	get_tree().paused = false
	hide()
func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
