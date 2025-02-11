extends TextureRect

var mainGame = preload("res://scenes/levels/main.tscn")
var settingsMenu = preload("res://scenes/menus/settings.tscn")
var settingsAdded = false
var firstRun = true

# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().size = DisplayServer.screen_get_size()
	connect("visibility_changed", _on_visible_changed)
	
	get_node("PlayButton").connect("pressed", _start_game)
	get_node("SettingsButton").connect("pressed", _open_settings)
	get_node("ExitButton").connect("pressed", _exit_game)


func handleConsoleArgs():
	var hasArgs = false
	var curArgName : String
	var curArgData : String
	for argument in OS.get_cmdline_user_args():
		hasArgs = true
		curArgName = argument.lstrip("-").split("=")[0]
		curArgData = argument.split("=")[1]
		match curArgName:
			"arnold":
				Main.arnoldInit = int(curArgData)
			"food":
				Main.foodInit = int(curArgData)
			"platform-size", "p-size":
				Main.platformSize = float(curArgData)
			"player-hp", "hp":
				Player.hpInit = int(curArgData)
	
	if hasArgs:
		get_node("PlayButton").emit_signal("pressed")


func _start_game():
	get_parent().hide()
	get_tree().root.add_child(mainGame.instantiate())


func _open_settings():
	get_parent().hide()
	if not settingsAdded:
		settingsAdded = true
		get_tree().root.add_child(settingsMenu.instantiate())
	else:
		get_tree().root.get_node("Settings").show()


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
	if firstRun:
		firstRun = false
		handleConsoleArgs()
