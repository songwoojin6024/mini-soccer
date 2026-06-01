extends Node

var current_match = 0
var player_alive = true
var relic_unlocked = false
var selected_relic_name = ""
var selected_relic_image = ""
var selected_character_id = 0
var team_characters = {}


func _ready():
	randomize()
	
var characters = [
	{
		"name": "호날두",
		"frames": "res://characters/character_1_spriteframes.tres",
		"preview": "res://image soccer/player/walk.png",
		"preview_scale": 0.22,
		"scale": 0.25
	},
	{
		"name": "손흥민",
		"frames": "res://characters/character_2_spriteframes.tres",
		"preview": "res://image soccer/player/walk_Son.png",
		"preview_scale": 0.22,
		"scale": 0.25
	},
	{
		"name": "음바페",
		"frames": "res://characters/character_3_spriteframes.tres",
		"preview": "res://image soccer/player/walk_m.png",
		"preview_scale": 0.22,
		"scale": 0.25
	},
	{
		"name": "그리즈만",
		"frames": "res://characters/character_4_spriteframes.tres",
		"preview": "res://image soccer/player/walk_G.png",
		"preview_scale": 0.18,
		"scale": 0.22
	},
	{
		"name": "홀란드",
		"frames": "res://characters/character_5_spriteframes.tres",
		"preview": "res://image soccer/player/walk_h.png",
		"preview_scale": 0.18,
		"scale": 0.22
	},
	{
		"name": "메시",
		"frames": "res://characters/character_6_spriteframes.tres",
		"preview": "res://image soccer/player/walk_L.png",
		"preview_scale": 0.18,
		"scale": 0.22
	},
	{
		"name": "케인",
		"frames": "res://characters/character_7_spriteframes.tres",
		"preview": "res://image soccer/player/walk_k.png",
		"preview_scale": 0.18,
		"scale": 0.22
	},
	{
		"name": "브루노 페르난데스",
		"frames": "res://characters/character_8_spriteframes.tres",
		"preview": "res://image soccer/player/walk_B.png",
		"preview_scale": 0.18,
		"scale": 0.22
	}
]
func setup_random_bracket():
	var ai_teams = ["AI 1", "AI 2", "AI 3", "AI 4", "AI 5", "AI 6", "AI 7"]
	ai_teams.shuffle()

	round_of_8 = [
		["YOU", ai_teams[0]],
		[ai_teams[1], ai_teams[2]],
		[ai_teams[3], ai_teams[4]],
		[ai_teams[5], ai_teams[6]]
	]
func setup_team_characters():
	team_characters.clear()
	team_characters["YOU"] = selected_character_id

	var available_character_ids = []

	for i in range(characters.size()):
		if i != selected_character_id:
			available_character_ids.append(i)

	var ai_teams = ["AI 1", "AI 2", "AI 3", "AI 4", "AI 5", "AI 6", "AI 7"]

	for i in range(ai_teams.size()):
		var character_id = available_character_ids[i % available_character_ids.size()]
		team_characters[ai_teams[i]] = character_id
# 8강 대진표
var round_of_8 = []

# 4강, 결승 결과
var semifinal = ["???", "???", "???", "???"]
var final_match = ["???", "???"]
var winner = ""

var player_score = 0
var ai_score = 0

func simulate_match(team1, team2):
	if randf() < 0.5:
		return team1
	else:
		return team2

var current_round = "8강"  # "8강", "4강", "결승"

func set_match_result(player_won: bool):
	if current_round == "8강":
		if player_won:
			semifinal[0] = "YOU"
		else:
			player_alive = false
			semifinal[0] = round_of_8[0][1]
		semifinal[1] = simulate_match(round_of_8[1][0], round_of_8[1][1])
		semifinal[2] = simulate_match(round_of_8[2][0], round_of_8[2][1])
		semifinal[3] = simulate_match(round_of_8[3][0], round_of_8[3][1])
		current_round = "4강"
	elif current_round == "4강":
		if player_won:
			final_match[0] = "YOU"
		else:
			player_alive = false
		final_match[1] = simulate_match(semifinal[2], semifinal[3])
		current_round = "결승"
	elif current_round == "결승":
		if player_won:
			winner = "YOU"
			relic_unlocked = true
			current_round = "우승"
		else:
			player_alive = false
	
func reset():
	current_match = 0
	current_round = "8강"
	player_alive = true
	semifinal = ["???", "???", "???", "???"]
	final_match = ["???", "???"]
	winner = ""
	relic_unlocked = false
	selected_relic_name = ""
	selected_relic_image = ""
	player_score = 0
	ai_score = 0
	setup_random_bracket()
	
func choose_player_character(character_id: int):
	selected_character_id = character_id
	setup_team_characters()
	setup_random_bracket()
	
func get_current_opponent_team():
	if current_round == "8강":
		return round_of_8[0][1]
	elif current_round == "4강":
		return semifinal[1]
	elif current_round == "결승":
		return final_match[1]
	return round_of_8[0][1]
	
func get_character_frames(team_name: String):
	if team_characters.is_empty():
		setup_team_characters()

	var character_id = team_characters.get(team_name, 0)
	return characters[character_id]["frames"]
func get_character_scale(team_name: String):
	if team_characters.is_empty():
		setup_team_characters()

	var character_id = team_characters.get(team_name, 0)
	return characters[character_id].get("scale", 0.3)
