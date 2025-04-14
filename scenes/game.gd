extends Node2D

@onready var lasers: Node = $Lasers
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("laser_shot", _on_player_laser_shot)


func _on_player_laser_shot(laser):
	lasers.add_child(laser)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
