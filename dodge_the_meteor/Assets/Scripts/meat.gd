extends Area2D

@export var lifetime = 5.0
var alive_time = 0.0

func _ready():
	var viewport_size = get_viewport_rect().size
	position = Vector2(randf() * viewport_size.x, viewport_size.y - 70)
	
func _process(delta):
	alive_time += delta
	if alive_time >= lifetime:
		queue_free()
		
func _on_area_entered(area):
	if area.name == "Player":
		if area.boost_time <= 0:
			area.boost_time = 10
		queue_free()		
