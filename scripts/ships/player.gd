extends CharacterBody2D

signal laser_shot(laser)

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0
@export var rate_of_fire := 0.15
@export var ship_size := 40.0
@export var ship_indicator_scale := 4
@export var max_charges := 10
@export var shape: ShapeBuilder.Type = ShapeBuilder.Type.TRIANGLE

@onready var muzzle: Node2D = $Muzzle
@onready var ship: Polygon2D = $Ship
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var right_indicator: Polygon2D = $RightIndicator/Polygon2D
@onready var left_indicator: Polygon2D = $LeftIndicator/Polygon2D


var laser_scene = preload("res://scenes/laser/laser.tscn")
var charges = null
var shoot_cd = false


func _ready() -> void:
	draw_new_ship()
	

func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if not shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

	if charges <= 0:
		draw_new_ship()
		

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
	charges -= 1
	var l = laser_scene.instantiate() as Laser
	l.global_position = muzzle.global_position
	l.rotation = rotation
	l.shape = shape
	emit_signal("laser_shot", l)
		
func draw_new_ship() -> void:
	charges = max_charges
	shape = ShapeBuilder.generate_random_shape(ship_size, ship)
	var ship_indicator_size = ship_size / ship_indicator_scale
	collision_polygon_2d.polygon = ship.polygon
	match shape:
		ShapeBuilder.Type.TRIANGLE:
			rate_of_fire = 0.15
			ShapeBuilder.generate_circle(ship_indicator_size, left_indicator)
			ShapeBuilder.generate_square(ship_indicator_size, right_indicator)
		ShapeBuilder.Type.CIRCLE:
			rate_of_fire = 0.5
			ShapeBuilder.generate_triangle(ship_indicator_size, left_indicator)
			ShapeBuilder.generate_square(ship_indicator_size, right_indicator)
		ShapeBuilder.Type.SQUARE:
			rate_of_fire = 0.15
			ShapeBuilder.generate_circle(ship_indicator_size, left_indicator)
			ShapeBuilder.generate_triangle(ship_indicator_size, right_indicator)

	right_indicator.color = Color.HOT_PINK
	left_indicator.color = Color.HOT_PINK
