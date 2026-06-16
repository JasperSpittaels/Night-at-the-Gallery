extends Control

@onready var escape_text: Label = $CenterContainer/VBoxContainer/Label

func _ready() -> void:
	escape_text.text = "You escaped with the Mona Lisa"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_return_to_main_menu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Scene.tscn")
