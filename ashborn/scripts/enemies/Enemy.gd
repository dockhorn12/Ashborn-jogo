extends CharacterBody2D

# Nome do inimigo para identificar no console
@export var enemy_name: String = "Inimigo"

func receber_dano() -> void:
	# Imprime no console que o inimigo foi atingido
	print(enemy_name + " foi atingido!")
