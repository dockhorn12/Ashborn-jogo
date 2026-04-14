extends CharacterBody2D

# --- Stats do Kael ---
var move_speed: float = 150.0  # Velocidade de movimento em pixels por segundo
var max_hp: int = 100           # Vida máxima
var current_hp: int = 100       # Vida atual

func _physics_process(_delta: float) -> void:
	# Lê o input nas 4 direções e retorna um vetor já normalizado (diagonal não é mais rápida)
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Multiplica a direção pela velocidade para definir quanto o personagem se move
	velocity = direction * move_speed

	# Aplica o movimento e faz o personagem deslizar ao colidir com obstáculos
	move_and_slide()
