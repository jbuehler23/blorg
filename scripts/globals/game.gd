extends Node2D

signal score_updated(score, boss_spawn_threshold)
signal grow_ship()

@onready var lasers: Node = $Lasers
@onready var player: Ship = $Player
@onready var asteroids: Node = $Asteroids
@export var asteroid_child_size := 2
@export var conehead_spawn_score := 100
@export var max_asteroids := 10
@export var infinite_asteroids := true
@export var asteroid_spawn_radius := 400

@onready var cone_head: ConeHead = $ConeHead
@onready var cone_head_animation_player: AnimationPlayer = $ConeHead/AnimationPlayer
@onready var mouth_open: Polygon2D = $ConeHead/Body/Head/MouthOpen
@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer
@onready var asteroid_spawner: Marker2D = $AsteroidSpawner
@onready var warning_overlay: WarningOverlay = $WarningOverlay
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var asteroid_scene = preload("res://scenes/asteroids/asteroid.tscn")
var conehead_spawned = false
var score: int = 0
var waiting_for_conehead_to_clear = true
var clearing_asteroids := false

@export var boss_threshold := 500
@export var boss_threshold_increment := 1000
var boss_triggered := false

@export var growth_threshold := 15
var playthroughs := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("laser_shot", _on_player_laser_shot)
	warning_overlay.connect("warning_finished", _on_warning_finished_flashing)
	if playthroughs > 1:
		player.ship_size = player.max_ship_size
		player.max_ship_size *= 1.2
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
	randomize()


func _on_player_laser_shot(laser):
	$LaserSFX.pitch_scale = randf_range(0.5, 1.0)
	$LaserSFX.play()
	lasers.add_child(laser)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	#if score >= 200 and not conehead_spawned:
		#spawn_conehead(cone_head.current_phase)
	#if conehead_spawned && waiting_for_conehead_to_clear and asteroids.get_child_count() == 0:
		#cone_head.fight()
		#waiting_for_conehead_to_clear = false
		#mouth_open.visible = false
		
func _on_asteroid_exploded(pos, size, points):
	if clearing_asteroids:
		return
	
	#$ExplodeSFX.pitch_scale = randf_range(0.5, 1.0)
	$ExplodeSFX.play()
		
	score += points
	score_updated.emit(score, boss_threshold)
	grow_ship.emit()
	for i in range(asteroid_child_size):
		match size:
			Asteroid.AsteroidSize.BOSS:
				$ExplodeSFX.pitch_scale = 0.5
				$ExplodeSFX.volume_db = 10.0
				$ExplodeSFX.play()
				spawn_asteroid(pos, Asteroid.AsteroidSize.LARGE)
				boss_triggered = false
				infinite_asteroids = true
				asteroid_spawn_timer.start()
			Asteroid.AsteroidSize.LARGE:
				$ExplodeSFX.pitch_scale = 0.7
				$ExplodeSFX.volume_db = 7.0
				$ExplodeSFX.play()
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				$ExplodeSFX.pitch_scale = 0.8
				$ExplodeSFX.volume_db = 8.0
				$ExplodeSFX.play()
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				$ExplodeSFX.pitch_scale = 1.0
				$ExplodeSFX.volume_db = 5.0
				$ExplodeSFX.play()
	
	if score >= boss_threshold and not boss_triggered:
		boss_triggered = true
		show_warning_then_spawn_boss()
		boss_threshold += randf_range(1500, 3000)
			

func show_warning_then_spawn_boss() -> void:
	warning_overlay.show_warning()

func _on_warning_finished_flashing() -> void:
	spawn_boss_asteroid()
	
func spawn_boss_asteroid() -> void:
	infinite_asteroids = false
	asteroid_spawn_timer.stop()
	clear_asteroids()
	#suck_asteroids()
	var spawn_pos = player.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * asteroid_spawn_radius
	spawn_asteroid(spawn_pos, Asteroid.AsteroidSize.BOSS)
	
func clear_asteroids() -> void:
	clearing_asteroids = true
	for asteroid in asteroids.get_children():
		asteroid.queue_free()
	await get_tree().process_frame # give it a frame to clear properly
	clearing_asteroids = false
	
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
	elif anim_name == "fly_away":
		clear_asteroids()
		modulate = Color.BLACK
		await get_tree().create_timer(5.8).timeout
		playthroughs += 1
		get_tree().call_deferred("reload_current_scene")

func suck_asteroids() -> void:
	for asteroid in asteroids.get_children():
		asteroid.start_sucking(mouth_open.global_position)
		


func _on_asteroid_spawn_timer_timeout() -> void:
	if not infinite_asteroids:
		return
	if asteroids.get_child_count() >= max_asteroids:
		return
		
	var spawn_pos = player.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * asteroid_spawn_radius
	#var spawn_pos = asteroid_spawner.position
	spawn_asteroid(spawn_pos, Asteroid.AsteroidSize.LARGE)
		


func _on_cone_head_died() -> void:
	infinite_asteroids = true
	asteroid_spawn_timer.start()


func _on_cone_head_reset() -> void:
	infinite_asteroids = true
	asteroid_spawn_timer.start()
	cone_head_animation_player.play("RESET")


func _on_player_win_game() -> void:
	Global.camera.shake(10, 8)
	$BackgroundMusic.pitch_scale = 5.0
	$BackgroundMusic.play()
	$ExplodeSFX.play()
	clear_asteroids()
	infinite_asteroids = false
	asteroid_spawn_timer.stop()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play("fly_away")
