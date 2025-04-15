extends Node2D

@onready var lasers: Node = $Lasers
@onready var player: CharacterBody2D = $Player
@onready var asteroids: Node = $Asteroids
@export var asteroid_child_size = 2

var asteroid_scene = preload("res://scenes/asteroids/asteroid.tscn")
var score: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("laser_shot", _on_player_laser_shot)
	
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)


func _on_player_laser_shot(laser):
	lasers.add_child(laser)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
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
	


func _on_player_died() -> void:
	#TODO: play a new scene or game over or something
	get_tree().call_deferred("reload_current_scene")
