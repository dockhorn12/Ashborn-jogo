extends CharacterBody2D

# --- Identificação ---
@export var enemy_name: String = "Inimigo"

# --- Vida ---
@export var max_hp: int = 30
var current_hp: int

# --- Referência ao visual para o efeito de piscar ---
@onready var visual: ColorRect = $Visual

# Cor original do inimigo (vermelho)
const COR_NORMAL  := Color(0.85, 0.2, 0.2, 1)
# Cor ao receber dano (branco)
const COR_DANO    := Color(1.0, 1.0, 1.0, 1)

func _ready() -> void:
	# Inicializa o HP atual com o valor máximo
	current_hp = max_hp

func receber_dano(quantidade: int) -> void:
	# Reduz o HP pela quantidade de dano recebida
	current_hp -= quantidade
	print("%s recebeu %d de dano — HP: %d/%d" % [enemy_name, quantidade, current_hp, max_hp])

	# Dispara o efeito visual de piscar
	_piscar()

	# Verifica se o inimigo morreu
	if current_hp <= 0:
		_morrer()

func _piscar() -> void:
	# Muda para branco imediatamente e volta ao vermelho após 0.1 segundos
	visual.color = COR_DANO
	await get_tree().create_timer(0.1).timeout
	# Verifica se o nó ainda existe antes de restaurar a cor (pode ter morrido)
	if is_instance_valid(self):
		visual.color = COR_NORMAL

func _morrer() -> void:
	# Imprime no console e remove o inimigo da cena
	print(enemy_name + " morreu!")
	queue_free()
