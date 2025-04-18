class_name ConeHead extends Area2D

signal take_damage(current_health, max_health)
signal died()
signal reset()
signal health_set(max_health)

@onready var muzzle: Node2D = $Muzzle
@onready var fire_timer: Timer = $FireTimer
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var head: Polygon2D = $Body/Head

##Seconds between shots
@export var fire_rate := 5.0
@export var spray_amount := 6
@export var spray_angle := 30.0
@export var move_speed := 100.0
@export var idle_time := 1.5
@export var shake_duration := 0.3
@export var shake_intensity := 4.0
@export var max_health := 100.0
@export var damage_multiplier := 1.0

var target_position: Vector2
var spawned := false
var is_moving := false
var idle_timer := 0.0
var shake_timer := 0.0
var original_position := Vector2.ZERO
var current_health = null
var current_phase = 0

var laser_scene = preload("res://scenes/laser/laser.tscn")

func fight() -> void:
	spawned = true
	current_phase += 1
	health_set.emit(max_health)
	set_phase_parameters(current_phase)
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	original_position = global_position
	pick_new_target()
	collision_polygon_2d.polygon = head.polygon

func set_phase_parameters(phase) -> void:
	fire_rate /= phase
	spray_amount *= 1.2
	move_speed *= phase * 1.2
	idle_time /= 1.2
	max_health *= 1.5
	current_health = max_health
	damage_multiplier *= 1.2

func _physics_process(delta: float) -> void:
	if spawned:
		if shake_timer > 0:
			shake_timer -= delta
			global_position = original_position + Vector2(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)
			if shake_timer <= 0:
				global_position = original_position
				fire_lasers()
		if is_moving:
			var direction = (target_position - global_position).normalized()
			global_position += direction * move_speed * delta
			
			if global_position.distance_to(target_position) < 10:
				is_moving = false
				idle_timer = idle_time
		else:
			idle_timer -= delta
			if idle_timer <= 0:
				pick_new_target()
			
func pick_new_target() -> void:
	var screen_size = get_viewport_rect().size
	var margin = 50
	target_position = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
	)
	is_moving = true

func fire_lasers():
	if not spawned:
		return
	for i in spray_amount:
		var laser = laser_scene.instantiate() as Laser
		var angle_offset = deg_to_rad(randf_range(-spray_angle / 2, spray_angle / 2))
		var direction = Vector2.LEFT.rotated(angle_offset)

		laser.shape = ShapeBuilder.Type.CIRCLE
		laser.global_position = muzzle.global_position
		laser.rotation = direction.angle()
		laser.damage_multiplier = damage_multiplier
		get_tree().current_scene.add_child(laser)

func damage(amount: int) -> void:
	current_health -= amount
	take_damage.emit(current_health, max_health)
	if current_health <= 0:
		if current_phase == 3:
			died.emit()
		else:
			spawned = false
			reset.emit()
	
	
func _on_fire_timer_timeout() -> void:
	original_position = global_position
	shake_timer = shake_duration
	

func _on_body_entered(body: Node2D) -> void:
	if body is Ship:
		var ship = body as Ship
		ship.damage(50)
