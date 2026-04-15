extends CanvasLayer

# Referências aos nós visuais
@onready var barra_fill: ColorRect    = $Control/BarraHP/Fill
@onready var label_hp: Label          = $Control/LabelHP
@onready var label_essencia: Label    = $Control/LabelEssencia
@onready var label_flechas: Label     = $Control/LabelFlechas
@onready var label_inimigos: Label    = $Control/LabelInimigos

# Largura máxima da barra (em pixels)
const LARGURA_MAX: float = 200.0

# Atualiza a barra e o texto de HP
func atualizar_hp(atual: int, maximo: int) -> void:
	var proporcao := float(atual) / float(maximo)
	barra_fill.size.x = LARGURA_MAX * proporcao
	label_hp.text = "HP: %d / %d" % [atual, maximo]

# Atualiza o total de essência coletada
func atualizar_essencia(total: int) -> void:
	label_essencia.text = "Essência: %d" % total

func atualizar_flechas(total: int) -> void:
	label_flechas.text = "Flechas: %d" % total

# Atualiza o contador de inimigos vivos
func atualizar_inimigos(quantidade: int) -> void:
	label_inimigos.text = "Inimigos: %d" % quantidade

# Exibe mensagem temporária de sala limpa
func mostrar_sala_limpa() -> void:
	label_inimigos.text = "Sala limpa!"
