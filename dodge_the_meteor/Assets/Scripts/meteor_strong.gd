extends Area2D

@export var fall_speed = 300

func _process(delta):
	position.y += fall_speed * delta
	if position.y > get_viewport_rect().size.y:
		queue_free()

func _on_area_entered(area):
	if area.name == "Player":
		area.take_damage(30)
		print(area.current_hp)
		queue_free()
