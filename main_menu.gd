extends TextureRect

var mainGame = preload("res://main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().size = DisplayServer.screen_get_size()
	connect("visibility_changed", _on_visible_changed)
	
	get_node("PlayButton").connect("pressed", _start_game)
	get_node("SettingsButton").connect("pressed", _open_settings)
	get_node("ExitButton").connect("pressed", _exit_game)


func _start_game():
	get_parent().hide()
	get_tree().root.add_child(mainGame.instantiate())


func _open_settings():
	pass


func _exit_game():
	get_tree().quit()


func _on_visible_changed():
	var mainMenuMusic = get_parent().get_node("MainMenuMusic")
	if visible:
		mainMenuMusic.seek(0.0)
		mainMenuMusic.play()
	else:
		mainMenuMusic.stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
