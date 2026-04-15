extends CharacterBody2D

# --- Identificação ---
@export var enemy_name: String = "Inimigo"

# --- Vida ---
@export var max_hp: int = 30
var current_hp: int

# --- Dano causado ao player por contato ---
@export var dano_contato: int = 10

# --- Referências ---
@onready var visual: ColorRect = $Visual
@onready var contact_area: Area2D = $ContactArea

# Cores para o efeito de piscar
const COR_NORMAL := Color(0.85, 0.2, 0.2, 1)
const COR_DANO   := Color(1.0, 1.0, 1.0, 1)

func _ready() -> void:
	current_hp = max_hp

func _physics_process(_delta: float) -> void:
	# Verifica a cada frame se o player está dentro da área de contato
	for body in contact_area.get_overlapping_bodies():
		if body.has_method("receber_dano_contato"):
			body.receber_dano_contato(dano_contato)

func receber_dano(quantidade: int) -> void:
	current_hp -= quantidade
	print("%s recebeu %d de dano — HP: %d/%d" % [enemy_name, quantidade, current_hp, max_hp])
	_piscar()
	if current_hp <= 0:
		_morrer()

func _piscar() -> void:
	visual.color = COR_DANO
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		visual.color = COR_NORMAL

func _morrer() -> void:
	print(enemy_name + " morreu!")
	queue_free()
