extends Control

@onready var character_select_panel = $CharacterSelectPanel
@onready var character_cards = [
	$CharacterSelectPanel/Card1,
	$CharacterSelectPanel/Card2,
	$CharacterSelectPanel/Card3,
	$CharacterSelectPanel/Card4,
	$CharacterSelectPanel/Card5,
	$CharacterSelectPanel/Card6,
	$CharacterSelectPanel/Card7,
	$CharacterSelectPanel/Card8
]

func _ready():
	$HowToPlayPanel.visible = false
	character_select_panel.visible = false

	$StartButton.pressed.connect(_on_start_button_pressed)
	$HowToPlayButton.pressed.connect(_on_how_to_play_button_pressed)
	$HowToPlayPanel/CloseButton.pressed.connect(_on_close_button_pressed)
	$CharacterSelectPanel/CloseButton.pressed.connect(_on_character_select_close_pressed)

	for i in range(character_cards.size()):
		character_cards[i].pressed.connect(_on_character_card_pressed.bind(i))

func _on_start_button_pressed():
	show_character_select()

func show_character_select():
	$TitleLabel.visible = false
	$StartButton.visible = false
	$HowToPlayButton.visible = false

	refresh_character_cards()
	character_select_panel.visible = true

func refresh_character_cards():
	for i in range(character_cards.size()):
		var card = character_cards[i]
		var preview = card.get_node("Preview")
		var name_label = card.get_node("NameLabel")

		if i < GameManager.characters.size():
			var character = GameManager.characters[i]

			card.disabled = false
			preview.visible = true
			name_label.text = character["name"]

			preview.texture = load(character["preview"])
			var preview_scale = character.get("preview_scale", 0.12)
			preview.scale = Vector2(preview_scale, preview_scale)
		else:
			card.disabled = true
			preview.visible = false
			name_label.text = "준비중"

func _on_character_card_pressed(character_id: int):
	if character_id >= GameManager.characters.size():
		return

	GameManager.choose_player_character(character_id)
	get_tree().change_scene_to_file("res://tournament.tscn")

func _on_character_select_close_pressed():
	character_select_panel.visible = false
	$TitleLabel.visible = true
	$StartButton.visible = true
	$HowToPlayButton.visible = true

func _on_how_to_play_button_pressed():
	$HowToPlayPanel.visible = true

func _on_close_button_pressed():
	$HowToPlayPanel.visible = false
