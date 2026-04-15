extends Node2D

# Conecta o sinal de HP do player ao HUD ao iniciar a cena
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	player.hp_changed.connect(hud.atualizar_hp)
