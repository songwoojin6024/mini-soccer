extends Panel

@onready var main = get_tree().current_scene

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		main.hide_pause_menu()
		get_viewport().set_input_as_handled()
