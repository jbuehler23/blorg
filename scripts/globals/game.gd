extends Node2D

@onready var lasers: Node = $Lasers
@onready var player: CharacterBody2D = $Player
@onready var asteroids: Node = $Asteroids
@export var asteroid_child_size := 2
@export var conehead_spawn_score := 100
@export var max_asteroids := 7
@export var infinite_asteroids := true
@export var asteroid_spawn_radius := 400

@onready var cone_head: ConeHead = $ConeHead
@onready var cone_head_animation_player: AnimationPlayer = $ConeHead/AnimationPlayer
@onready var mouth_open: Polygon2D = $ConeHead/Body/Head/MouthOpen
@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer

var asteroid_scene = preload("res://scenes/asteroids/asteroid.tscn")
var conehead_spawned = false
var score: int = 0
var waiting_for_conehead_to_clear = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("laser_shot", _on_player_laser_shot)
	
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
	randomize()


func _on_player_laser_shot(laser):
	lasers.add_child(laser)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
	if score >= 200 and not conehead_spawned:
		spawn_conehead(cone_head.current_phase)
	if conehead_spawned && waiting_for_conehead_to_clear and asteroids.get_child_count() == 0:
		cone_head.fight()
		waiting_for_conehead_to_clear = false
		mouth_open.visible = false
		
func _on_asteroid_exploded(pos, size, points):
	score += points
	for i in range(asteroid_child_size):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass
			
	
func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.asteroid_size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
	
func spawn_conehead(phase: int) -> void:
	infinite_asteroids = false
	asteroid_spawn_timer.stop()
	if phase == 1:
		cone_head.scale = Vector2.ONE
	if phase == 2:
		cone_head.scale = Vector2.ONE * 2
	if phase == 3:
		cone_head.scale = Vector2.ONE * 3
	cone_head_animation_player.play("conehead_spawn")
	conehead_spawned = true
	

func _on_player_died() -> void:
	#TODO: play a new scene or game over or something
	get_tree().call_deferred("reload_current_scene")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "conehead_spawn":
		mouth_open.visible = true
		suck_asteroids()

func suck_asteroids() -> void:
	for asteroid in asteroids.get_children():
		asteroid.start_sucking(mouth_open.global_position)
	waiting_for_conehead_to_clear = true
		


func _on_asteroid_spawn_timer_timeout() -> void:
	if not infinite_asteroids:
		return
	if asteroids.get_child_count() >= max_asteroids:
		return
		
	var spawn_pos = player.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * asteroid_spawn_radius
	spawn_asteroid(spawn_pos, Asteroid.AsteroidSize.LARGE)
		


func _on_cone_head_died() -> void:
	infinite_asteroids = true
	asteroid_spawn_timer.start()
