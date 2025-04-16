extends Control
@onready var charges_bar: ProgressBar = $HBoxContainer/ChargesBar
@onready var health_bar: ProgressBar = $HBoxContainer/HealthBar

func _on_player_charge_changed(charges: float, max_charges: float) -> void:
	charges_bar.value = charges * 100 / max_charges


func _on_player_take_damage(damage: float, max_health: float) -> void:
	health_bar.value = damage * 100 / max_health
	


func _on_cone_head_take_damage(damage: Variant, max_health: Variant) -> void:
	health_bar.value = damage * 100 / max_health
