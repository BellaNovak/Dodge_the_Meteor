extends Node2D

@onready var meteor_scene = preload("res://Scenes/meteor.tscn")
@onready var meteor_strong_scene = preload("res://Scenes/meteor_strong.tscn")
@onready var meat_scene = preload("res://Scenes/meat.tscn")
@onready var human_scene = preload("res://Scenes/human.tscn")
@onready var helath_bar = $UI/HealthBar
@onready var timer_label = $UI/TimerLabel
@onready var phase_complete_label = $UI/PhaseComplete
@onready var pause_button = $UI/PauseButton

@export var phase_data = [
	{"time": 61, "player_hp": 100, "meteor_spawn_time": 1.25, "meteor_strong_spawn_time": 70.0, "meat_spawn_time": 15.0, "human_spawn_time": 70.0},
	{"time": 91, "player_hp": 80, "meteor_spawn_time": 100.0, "meteor_strong_spawn_time": 1.1, "meat_spawn_time": 100.0, "human_spawn_time": 25.0},
	{"time": 121, "player_hp": 70, "meteor_spawn_time": 1.0, "meteor_strong_spawn_time": 4.0, "meat_spawn_time": 40.0, "human_spawn_time": 45.0},
]

var current_phase = 0
var phase_time = 60
var elapsed_time = 0.0
var is_phase_running = false
var is_paused = false

func _ready():
	start_phase(current_phase)
	$Player.connect("player_died", game_over)
	$Player.connect("player_heal", update_ui)
	$Player.connect("player_hit", update_ui)
	#update_ui()
		
func _process(delta):
	if is_phase_running and not is_paused:
		elapsed_time += delta
		var remaining_time = phase_time - elapsed_time
		timer_label.text = str(floor(remaining_time))
	
		if remaining_time < 1:
			is_phase_running = false
			next_phase()
		#if elapsed_time >= phase_data[current_phase]["time"]:
			#next_phase()	
	
func update_ui():
	#print($Player.current_hp)
	helath_bar.value = $Player.current_hp
	timer_label.text = str(phase_time)
	
func start_phase(phase_index):
	current_phase = phase_index
	$Player.boost_time = 0
	elapsed_time = 0.0
	phase_time = phase_data[current_phase]["time"]
	timer_label.text = str(phase_time)
	
	var phase = phase_data[current_phase]
	$Player.current_hp = phase["player_hp"]
	helath_bar.value = phase["player_hp"]
	$MeteorSpawner.wait_time = phase["meteor_spawn_time"]
	$MeteorSpawner.start()
	
	$MeteorStrongSpawner.wait_time = phase["meteor_strong_spawn_time"]
	$MeteorStrongSpawner.start()
	
	$MeatSpawner.wait_time = phase["meat_spawn_time"]
	$MeatSpawner.start()
	
	$HumanSpawner.wait_time = phase["human_spawn_time"]
	$HumanSpawner.start()
	
	phase_complete_label.visible = false
	is_phase_running = true
			
func next_phase():
	$MeteorSpawner.stop()
	$MeteorStrongSpawner.stop()
	$HumanSpawner.stop()
	$MeatSpawner.stop()
	
	clear_objects()
	
	is_phase_running = false
	
	phase_complete_label.visible = true
	phase_complete_label.text = "Phase Complete"
	
	await wait(5.0)
	
	if current_phase < phase_data.size() - 1:
		start_phase(current_phase + 1)
	else:
		phase_complete_label.text = "Game Complete!"
		await wait(3.0)
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		queue_free()
		
func restart_phase():
	start_phase(current_phase)
	
func game_over():
	$MeteorSpawner.stop()
	$MeteorStrongSpawner.stop()
	$HumanSpawner.stop()
	$MeatSpawner.stop()	
	clear_objects()
	
	is_phase_running = false
	
	phase_complete_label.visible = true
	phase_complete_label.text = "Game Over"
	
	await wait(5.0)

	restart_phase()
	
func clear_objects():
	get_tree().call_group("objects_to_clear", "queue_free")
								
func wait(seconds):
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.start()	
	
	await timer.timeout
	timer.queue_free()	
		
func _on_meteor_spawner_timeout():
	var meteor = meteor_scene.instantiate()
	meteor.position = Vector2(randf() * get_viewport_rect().size.x, -50)
	add_child(meteor)
	meteor.add_to_group("objects_to_clear")

func _on_human_spawner_timeout():
	var human = human_scene.instantiate()
	#human.position = Vector2(randf() * get_viewport_rect().size.x, -500)
	add_child(human)
	human.add_to_group("objects_to_clear")

func _on_meat_spawner_timeout():
	var meat = meat_scene.instantiate()
	#meat.position = Vector2(randf() * get_viewport_rect().size.x, -500)
	add_child(meat)
	meat.add_to_group("objects_to_clear")

func _on_meteor_strong_spawner_timeout():
	var meteor_strong = meteor_strong_scene.instantiate()
	meteor_strong.position = Vector2(randf() * get_viewport_rect().size.x, -50)
	add_child(meteor_strong)
	meteor_strong.add_to_group("objects_to_clear")

func _on_pause_button_pressed():
	if not get_tree().paused:
		_pause_game()
	else:
		_resume_game()	
	
func _pause_game():
	is_paused = true
	get_tree().paused = true

func _resume_game():
	is_paused = false
	get_tree().paused = false
