extends Node

const SAVE_PATH = "user://highscore.save"
var high_score = 0

func _ready():
	load_score()

func save_score(new_score):
	if new_score > high_score:
		high_score = new_score
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		file.store_32(high_score)
		file.close()

func load_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		high_score = file.get_32()
		file.close()
