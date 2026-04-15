extends Node2D

# Tamanho de cada tile em pixels
const TILE_SIZE := 32

# Dimensões do mapa em tiles
const MAP_WIDTH  := 20
const MAP_HEIGHT := 15

# ID da fonte de tiles no TileSet
const SOURCE_ID := 0

# Coordenadas dos tiles dentro do atlas (coluna, linha)
const TILE_FLOOR := Vector2i(0, 0)
const TILE_WALL  := Vector2i(1, 0)

@onready var tile_map: TileMap = $TileMap

func _ready() -> void:
	# Cria o TileSet com os tiles placeholder e o aplica ao TileMap
	tile_map.tile_set = _criar_tileset()

	# Gera o layout do mapa (bordas + paredes internas)
	_gerar_mapa()

# Cria um TileSet com dois tiles coloridos e colisão nas paredes
func _criar_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	# Adiciona uma camada de física usando a layer World (bit 0 = layer 1)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)

	# Cria uma imagem com dois tiles lado a lado: chão (verde) e parede (cinza)
	var img := Image.create(TILE_SIZE * 2, TILE_SIZE, false, Image.FORMAT_RGB8)

	# Pinta o tile de chão (verde escuro)
	for x in range(TILE_SIZE):
		for y in range(TILE_SIZE):
			img.set_pixel(x, y, Color(0.18, 0.42, 0.18))

	# Pinta o tile de parede (cinza azulado)
	for x in range(TILE_SIZE, TILE_SIZE * 2):
		for y in range(TILE_SIZE):
			img.set_pixel(x, y, Color(0.45, 0.45, 0.52))

	# Cria o atlas e registra os dois tiles
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(img)
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	atlas.create_tile(TILE_FLOOR)
	atlas.create_tile(TILE_WALL)

	# Adiciona um polígono de colisão quadrado ao tile de parede
	var wall_data := atlas.get_tile_data(TILE_WALL, 0)
	wall_data.set_collision_polygons_count(0, 1)
	wall_data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16),
		Vector2(16,  16),  Vector2(-16, 16)
	]))

	ts.add_source(atlas, SOURCE_ID)
	return ts

# Preenche o TileMap com chão, bordas e algumas paredes internas
func _gerar_mapa() -> void:
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			# Borda do mapa é sempre parede
			var borda := (x == 0 or x == MAP_WIDTH - 1 or y == 0 or y == MAP_HEIGHT - 1)

			# Paredes internas para o jogador testar colisões
			var parede_interna := (x == 8 and y >= 3 and y <= 9) \
							   or (x == 13 and y >= 5 and y <= 12)

			if borda or parede_interna:
				tile_map.set_cell(0, Vector2i(x, y), SOURCE_ID, TILE_WALL)
			else:
				tile_map.set_cell(0, Vector2i(x, y), SOURCE_ID, TILE_FLOOR)
