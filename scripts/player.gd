extends CharacterBody2D

signal laser_shot(laser)

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0
@export var rate_of_fire := 0.15

@onready var muzzle: Node2D = $Muzzle


var laser_scene = preload("res://scenes/laser/laser.tscn")

var shoot_cd = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if not shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

func _physics_process(delta: float) -> void:
	var direction := Vector2(0, Input.get_axis("forward", "backward"))
	#-1, 0, 1 -> 0, -1 for forward
	velocity += direction.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
	
	#slow down the ship to stop (with floating effect)
	if direction.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
	
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	#player is outside (above) - teleport to bottom
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

func shoot_laser():
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)
		
	
