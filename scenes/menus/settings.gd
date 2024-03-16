extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("BackButton").connect("pressed", _on_back_pressed)
	get_node("PlatformSizeSlider").connect("value_changed", _on_platform_size_changed)
	get_node("ArnoldSlider").connect("value_changed", _on_arnold_changed)
	get_node("FoodSlider").connect("value_changed", _on_food_changed)
	get_node("PlayerHPSlider").connect("value_changed", _on_player_hp_changed)


func _on_back_pressed():
	get_tree().root.get_node("MainMenu").show()
	get_parent().hide()


func _on_platform_size_changed(value):
	Main.platformSize = value
	get_node("PlatformSizeLabel").text = "Platform Size: " + str(value)


func _on_arnold_changed(value):
	Main.arnoldInit = value
	get_node("ArnoldLabel").text = "Arnold Amount: " + str(value)


func _on_food_changed(value):
	Main.foodInit = value
	get_node("FoodLabel").text = "Food Amount: " + str(value)


func _on_player_hp_changed(value):
	Player.hpInit = value
	get_node("PlayerHPLabel").text = "Player HP: " + str(value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("exit"):
		_on_back_pressed()
