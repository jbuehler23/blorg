class_name Ship extends CharacterBody2D

signal laser_shot(laser)
signal charge_changed(charges, max_charges)
signal died()
signal take_damage(damage, max_health)
signal request_grow()
signal win_game()

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0
@export var rate_of_fire := 0.15
@export var recharge_cooldown := 3.0
@export var ship_size := 40.0
@export var ship_indicator_scale := 4
@export var max_charges := 20
@export var max_ship_size := 100.0
@export var growth_step := 3.0

@export var max_health := 100.0
var current_health

@export var shape: ShapeBuilder.Type = ShapeBuilder.Type.TRIANGLE

@onready var muzzle: Node2D = $Ship/Muzzle
@onready var ship: Polygon2D = $Ship
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var right_indicator: Polygon2D = $Ship/RightIndicator/Polygon2D
@onready var left_indicator: Polygon2D = $Ship/LeftIndicator/Polygon2D
@onready var flash_timer: Timer = $FlashTimer

var can_fire: bool = true

var laser_scene = preload("res://scenes/laser/laser.tscn")
var charges = null
var shoot_cd = false



func _ready() -> void:
	current_health = max_health
	draw_new_ship(false)
	can_fire = true
	charges = max_charges
	

func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_fire:
		if not shoot_cd and charges > 0:
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
	match shape:
		ShapeBuilder.Type.TRIANGLE:
			await triangle_burst()
		ShapeBuilder.Type.CIRCLE:
			shotgun_blast()
		ShapeBuilder.Type.SQUARE:
			normal_shot()
	emit_signal("charge_changed", charges, max_charges)
	
	if charges <= 0:
		can_fire = false
		flash_timer.start()
		$ReloadSFX.play()
		await get_tree().create_timer(recharge_cooldown).timeout
		charges = max_charges
		can_fire = true
		draw_new_ship(false)
		ship.modulate = Color.WHITE
		emit_signal("charge_changed", charges, max_charges)

func shotgun_blast() -> void:
	var count = 5
	var spread = deg_to_rad(30.0)
	var half = count / 2
	for i in count:
		var angle = rotation + (i - half) * (spread / count)
		var l = laser_scene.instantiate() as Laser
		l.global_position = muzzle.global_position
		l.rotation = angle
		l.shape = shape
		emit_signal("laser_shot", l)
		Global.camera.shake(0.2, 3)
	charges -= count

func normal_shot() -> void:
	fire_laser()

func triangle_burst() -> void:
	if charges >= 3:
		for i in 3:
			fire_laser()
			await get_tree().create_timer(0.1).timeout
	else:
		fire_laser()
		
func fire_laser() -> void:
	charges -= 1
	var l = laser_scene.instantiate() as Laser
	l.global_position = muzzle.global_position
	l.rotation = rotation
	l.shape = shape
	emit_signal("laser_shot", l)
	Global.camera.shake(0.2, 3)
	
func draw_new_ship(use_current_shape: bool = true) -> void:
	if use_current_shape:
		shape = ShapeBuilder.resize_shape(ship_size, ship, shape)
	else:
		shape = ShapeBuilder.generate_random_shape(ship_size, ship)
	var ship_indicator_size = ship_size / ship_indicator_scale
	collision_polygon_2d.set_deferred("polygon", ship.polygon)

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

func damage(amount: float) -> void:
	current_health -= amount
	take_damage.emit(current_health, max_health)
	if current_health <= 0:
		die()

func die():
	Global.camera.shake(4, 15)
	$DieSFX.pitch_scale = 1.5
	$DieSFX.play()



func _on_flash_timer_timeout() -> void:
	if not can_fire:
		if ship.modulate == Color.WHITE:
			ship.modulate = Color.RED
		else:
			ship.modulate = Color.WHITE
	else:
		ship.modulate = Color.WHITE
		flash_timer.stop()


func _on_game_grow_ship() -> void:
	if ship_size >= max_ship_size:
		finale()
	
	ship_size += growth_step
	draw_new_ship()
	
func finale() -> void:
	win_game.emit()


func _on_die_sfx_finished() -> void:
	died.emit()
	#ship.visible = false
	#process_mode = Node.PROCESS_MODE_DISABLED
	queue_free()
