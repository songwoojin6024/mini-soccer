extends Control

@onready var champion_panel = $ChampionPanel
@onready var relic_image = $ChampionPanel/RelicImage
@onready var relic_name_label = $ChampionPanel/RelicNameLabel
@onready var new_tournament_button = $ChampionPanel/NewTournamentButton

var sf_labels = []
var bracket_lines = []  # 선 저장
var bracket_line_points = []
var relics = [
	{
		"name": "고려 청자",
		"image": "res://image soccer/Environment/유물1.png",
		"pos": Vector2(506, 159),
		"size": Vector2(120, 224)
	},
	{
		"name": "빗살무늬토기",
		"image": "res://image soccer/Environment/유물2.png",
		"pos": Vector2(369, -41),
		"size": Vector2(391, 639)
	},
	{
		"name": "백자청화 운용문 병",
		"image": "res://image soccer/Environment/유물3.png",
		"pos": Vector2(508, 156),
		"size": Vector2(124, 224)
	}
]
func _ready():
	draw_bracket()
	new_tournament_button.pressed.connect(_on_new_tournament_button_pressed)
	$StartMatchButton.pressed.connect(_on_start_match_pressed)
	$StartMatchButton.position = Vector2(476, 520)
	$StartMatchButton.size = Vector2(200, 50)

	if GameManager.winner == "YOU":
		show_champion_reward()
		return

	if not GameManager.player_alive:
		await show_eliminated_then_reset()
		return

	update_bracket()
func _on_new_tournament_button_pressed():
	GameManager.reset()
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func hide_tournament_ui():
	for child in get_children():
		child.visible = false
		
		
func show_eliminated_then_reset():
	hide_tournament_ui()

	var bg = TextureRect.new()
	bg.texture = load("res://image soccer/Environment/background.png")
	bg.position = Vector2(0, 0)
	bg.size = Vector2(1152, 648)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)

	var eliminated_label = Label.new()
	eliminated_label.text = "토너먼트 탈락!\n새 토너먼트로 돌아갑니다."
	eliminated_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eliminated_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	eliminated_label.position = Vector2(0, 180)
	eliminated_label.size = Vector2(1152, 220)
	eliminated_label.add_theme_font_size_override("font_size", 46)
	eliminated_label.add_theme_color_override("font_color", Color.RED)
	add_child(eliminated_label)

	await get_tree().create_timer(3.0).timeout

	GameManager.reset()
	get_tree().change_scene_to_file("res://tournament.tscn")
	
func _on_start_match_pressed():
	if not GameManager.player_alive:
		GameManager.reset()
		get_tree().change_scene_to_file("res://tournament.tscn")
	else:
		get_tree().change_scene_to_file("res://main.tscn")

func update_bracket():
	# 4강 라벨 업데이트
	for i in range(4):
		if i < sf_labels.size():
			sf_labels[i].text = GameManager.semifinal[i]

	# 결승 칸 업데이트
	if sf_labels.size() > 4:
		if GameManager.winner != "":
			sf_labels[4].text = GameManager.winner
		elif GameManager.final_match[0] != "???" and GameManager.final_match[1] != "???":
			sf_labels[4].text = GameManager.final_match[0] + "   vs   " + GameManager.final_match[1]
		else:
			sf_labels[4].text = "???"

	# 8강 승자 선 색칠
	if GameManager.current_round == "4강":
		if GameManager.semifinal[0] == GameManager.round_of_8[0][0]:
			highlight_line(0, Color.YELLOW)
		else:
			highlight_line(1, Color.CYAN)

		if GameManager.semifinal[1] == GameManager.round_of_8[1][0]:
			highlight_line(2, Color.CYAN)
		else:
			highlight_line(3, Color.CYAN)

		if GameManager.semifinal[2] == GameManager.round_of_8[2][0]:
			highlight_line(4, Color.CYAN)
		else:
			highlight_line(5, Color.CYAN)

		if GameManager.semifinal[3] == GameManager.round_of_8[3][0]:
			highlight_line(6, Color.CYAN)
		else:
			highlight_line(7, Color.CYAN)

	# 4강 승자 선 색칠
	elif GameManager.current_round == "결승":
		if GameManager.final_match[0] == GameManager.semifinal[0]:
			highlight_line(8, Color.YELLOW)
		else:
			highlight_line(9, Color.YELLOW)

		if GameManager.final_match[1] == GameManager.semifinal[2]:
			highlight_line(10, Color.CYAN)
		else:
			highlight_line(11, Color.CYAN)


func show_champion_reward():
	hide_tournament_ui()

	var selected_relic = relics[randi() % relics.size()]

	var bg = TextureRect.new()
	bg.texture = load("res://image soccer/Environment/background.png")
	bg.position = Vector2(0, 0)
	bg.size = Vector2(1152, 648)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)

	var title = Label.new()
	title.text = "토너먼트 우승!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 60)
	title.size = Vector2(1152, 80)
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color.YELLOW)
	add_child(title)

	relic_image.texture = load(selected_relic["image"])
	relic_image.position = selected_relic["pos"]
	relic_image.size = selected_relic["size"]
	relic_image.scale = Vector2.ONE
	relic_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	relic_image.stretch_mode = TextureRect.STRETCH_SCALE

	relic_name_label.text = "유물 획득: " + selected_relic["name"]

	champion_panel.visible = true
	relic_image.visible = true
	relic_name_label.visible = true
	new_tournament_button.visible = true

	move_child(champion_panel, get_child_count() - 1)
	
	
func highlight_line(index: int, color: Color):
	if index >= bracket_line_points.size():
		return

	var from = bracket_line_points[index][0]
	var to = bracket_line_points[index][1]

	var animated_line = Line2D.new()
	animated_line.add_point(from)
	animated_line.add_point(from)
	animated_line.width = 4
	animated_line.default_color = color
	add_child(animated_line)

	var tween = create_tween()
	tween.tween_method(
		func(progress):
			animated_line.set_point_position(1, from.lerp(to, progress)),
		0.0,
		1.0,
		0.45
	)

func draw_bracket():
	# 8강 왼쪽
	add_team_box(Vector2(50, 80), GameManager.round_of_8[0][0])
	add_team_box(Vector2(50, 180), GameManager.round_of_8[0][1])
	add_team_box(Vector2(50, 300), GameManager.round_of_8[1][0])
	add_team_box(Vector2(50, 400), GameManager.round_of_8[1][1])
	# 8강 오른쪽
	add_team_box(Vector2(950, 80), GameManager.round_of_8[2][0])
	add_team_box(Vector2(950, 180), GameManager.round_of_8[2][1])
	add_team_box(Vector2(950, 300), GameManager.round_of_8[3][0])
	add_team_box(Vector2(950, 400), GameManager.round_of_8[3][1])
	
	# 4강 왼쪽
	add_empty_box(Vector2(280, 130))
	add_empty_box(Vector2(280, 350))
	
	# 4강 오른쪽
	add_empty_box(Vector2(700, 130))
	add_empty_box(Vector2(700, 350))
	
	# 결승
	add_empty_box(Vector2(500, 240))
	
	# 선
	add_line(Vector2(200, 105), Vector2(280, 155))  # 0 player → 4강
	add_line(Vector2(200, 205), Vector2(280, 155))  # 1 AI1 → 4강
	add_line(Vector2(200, 325), Vector2(280, 375))  # 2 AI2 → 4강
	add_line(Vector2(200, 425), Vector2(280, 375))  # 3 AI3 → 4강
	add_line(Vector2(950, 105), Vector2(850, 155))  # 4 AI4 → 4강
	add_line(Vector2(950, 205), Vector2(850, 155))  # 5 AI5 → 4강
	add_line(Vector2(950, 325), Vector2(850, 375))  # 6 AI6 → 4강
	add_line(Vector2(950, 425), Vector2(850, 375))  # 7 AI7 → 4강
	add_line(Vector2(430, 155), Vector2(500, 265))  # 8 왼쪽4강 → 결승
	add_line(Vector2(430, 375), Vector2(500, 265))  # 9 왼쪽4강 → 결승
	add_line(Vector2(700, 155), Vector2(650, 265))  # 10 오른쪽4강 → 결승
	add_line(Vector2(700, 375), Vector2(650, 265))  # 11 오른쪽4강 → 결승

func add_line(from: Vector2, to: Vector2):
	var line = Line2D.new()
	line.add_point(from)
	line.add_point(to)
	line.width = 2
	line.default_color = Color.WHITE
	add_child(line)

	bracket_lines.append(line)
	bracket_line_points.append([from, to])

func add_team_box(pos: Vector2, team_name: String):
	var panel = Panel.new()
	panel.position = pos
	panel.size = Vector2(150, 50)
	add_child(panel)
	
	var label = Label.new()
	label.text = team_name
	label.position = Vector2(0, 0)
	label.size = Vector2(150, 50)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)

func add_empty_box(pos: Vector2):
	var panel = Panel.new()
	panel.position = pos
	panel.size = Vector2(150, 50)
	add_child(panel)
	
	var label = Label.new()
	label.text = "???"
	label.position = Vector2(0, 0)
	label.size = Vector2(150, 50)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	sf_labels.append(label)
