extends Area2D

@export var speed = 200
@export var boosted_speed = 400
var boost_time = 0
var max_hp = 100
var current_hp 

@onready var player_sprite = $Sprite2D

signal player_died
signal player_heal
signal player_hit

func _ready():
	var viewport_size = get_viewport_rect().size
	position = Vector2(viewport_size.x / 2, viewport_size.y - 100)

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	
	# Ajustar a escala do sprite
	if velocity.x > 0:
		player_sprite.flip_h = false
	elif velocity.x < 0:
		player_sprite.flip_h = true
			
	if Input.is_action_pressed("boost") and boost_time > 0:
		velocity *= boosted_speed
		boost_time -= delta
	else:
		velocity *= speed

	position += velocity * delta
	clamp_position()
	
func clamp_position():
	var viewport_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, viewport_size.x)	

func take_damage(damage: int):
	current_hp -= damage
	current_hp = clamp(current_hp, 0, max_hp)
	emit_signal("player_hit")
	if current_hp <= 0:
		die()

func heal(amount: int):
	if current_hp < 100:
		current_hp += amount
		current_hp = min(current_hp, max_hp)
		emit_signal("player_heal")

func die():
	emit_signal("player_died")
