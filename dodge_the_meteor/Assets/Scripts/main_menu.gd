extends Control
	
func _on_phase_1_button_pressed():
	start_game_at_phase(0)

func _on_phase_2_button_pressed():
	start_game_at_phase(1)

func _on_phase_3_button_pressed():
	start_game_at_phase(2)
	
func start_game_at_phase(phase_index):
	var main_scene = preload("res://Scenes/main.tscn").instantiate()
	get_tree().root.add_child(main_scene)
	main_scene.start_phase(phase_index)
	queue_free()	
