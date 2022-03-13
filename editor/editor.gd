extends Control



# ==================
#   Objekte
# -----------

var cols: HBoxContainer
var viewContainer: ViewportContainer
var viewport: Viewport
var camera: Camera2D
var refSprite: Sprite
var grid_col_spinner: SpinBox
var grid_row_spinner: SpinBox
var posMap: PosMap = PosMap.new()
var fileDialog: FileDialog
var arrows: MultiMeshInstance2D
var rotationBar: HSlider
var point: Sprite

# ===================
#   Variablen
# ------------

var zoom: float = 1.0
var texture_size: Vector2
var half_texture_size: Vector2
var grid_size: Vector2
var grid_count_x: int = 16
var grid_count_y: int = 16
var grid_color: Color = Color(1,1,1,0.5)
var grid_index: Vector2 = Vector2.ZERO
var arrowTransform: Transform2D
var current_grid_pos: Vector2


# ==================
#   interne Variablen
# -----------

var _err
var is_right_mouseButton_pressed: bool = false
var dialogMode: String = ""

# ===================
#   Godot Intern
# ---------------

# Called when the node enters the scene tree for the first time.
func _ready():
	# Objekte zuordnen
	# ----------------
	cols = $Margin/cols
	viewContainer = $Margin/cols/ViewContainer
	viewport = $Margin/cols/ViewContainer/Viewport
	camera = $Margin/cols/ViewContainer/Viewport/Camera
	refSprite = $Margin/cols/ViewContainer/Viewport/Ref
	grid_col_spinner = $Margin/cols/Menue/Items/grid1/grid_cols
	grid_row_spinner = $Margin/cols/Menue/Items/grid2/grid_rows
	fileDialog = $FileDialog
	arrows = $Margin/cols/ViewContainer/Viewport/Arrows
	rotationBar = $Margin/cols/Menue/Items/rotation
	point = $Margin/cols/ViewContainer/Viewport/Point

	# Start Funktionen
	# -----------------

	check_viewport_size()
	show_gird_values()
	
	texture_size = refSprite.texture.get_size()
	
	
	# ================
	# Signale
	# --------

	# Größenänderung vom Editor
	_err = connect("resized", self, "check_viewport_size")

	# Referenz Image Drop
	_err = get_tree().connect("files_dropped", self, "_on_files_dropped")


func _process(_delta):
	# Imput einstellungen
	if Input.is_key_pressed(KEY_F):
		# Kamera zum Zentrum
		camera.position = Vector2(0,0) + half_texture_size

	# Pfeile anzeigen
	#if Input.is_key_pressed(KEY_P):
	#	show_arrows()

	
func _input(event):
	if event is InputEventMouse:
		if event.button_mask == 8:
			zoom -= 0.1
			zoom = clamp(zoom, 0.1, 15)
			camera.set_zoom(Vector2(zoom,zoom))
		if event.button_mask == 16:
			zoom += 0.1
			zoom = clamp(zoom, 0.1, 15)
			camera.set_zoom(Vector2(zoom,zoom))
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 2:
			is_right_mouseButton_pressed = true
		elif event.pressed and event.button_index == 1:
			is_right_mouseButton_pressed = false
			set_gridPos(refSprite.get_local_mouse_position())
			# print("position: ", refSprite.get_local_mouse_position())
		else:
			is_right_mouseButton_pressed = false

	if event is InputEventMouseMotion:
		if is_right_mouseButton_pressed:
			var relative: Vector2 = event.relative
			camera.position -= relative * zoom

	
# ===================
#   Funktionen
# -------------

# Grid Werte anzeigen
func show_gird_values():
	grid_col_spinner.value = grid_count_x
	grid_row_spinner.value = grid_count_y


# Viewport auf die Größe vom Container setzen
func check_viewport_size():
	viewport.size = viewContainer.rect_size


# Das Referenz Bild vom Pfad Laden
func load_ref_image(path: String):
	if !path or path == "":
		return
		
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.create_from_image(image)
	texture_size = texture.get_size()
	refSprite.texture = texture
	
	# Textur Masse ermitteln
	read_size()

	camera.position = Vector2(0,0) + half_texture_size


# ermitteln der Texturgröße
func read_size():
	half_texture_size = texture_size /2
	grid_size.x = texture_size.x / grid_count_x
	grid_size.y = texture_size.y / grid_count_y

	# Skalierung
	var scale = grid_size / 150
	arrowTransform = Transform2D(Vector2(1.0, 0.0) * scale.x, Vector2(0.0, 1.0) * scale.y, Vector2.ZERO)

	# neu zeichnen	
	refSprite.update()


# Posmap neu anlegen
func create_posMap():
	posMap.set_size(grid_count_x, grid_count_y)
	posMap.fill_values(0)
	show_arrows()

# posmap speichern
func save_posMap():
	dialogMode = "save_posmap"
	fileDialog.mode = FileDialog.MODE_SAVE_FILE
	fileDialog.filters = ["*.posm"]
	fileDialog.window_title = "save PosMap"
	fileDialog.show()

	
# posmap laden
func load_posMap():
	dialogMode = "load_posmap"
	fileDialog.mode = FileDialog.MODE_OPEN_FILE
	fileDialog.filters = ["*.posm"]
	fileDialog.window_title = "load PosMap"
	fileDialog.show()

# posMap Daten lesen
func get_posMap_data():
	var size: Vector2 = posMap.get_size()
	grid_count_x = size.x
	grid_count_y = size.y
	show_gird_values()
	read_size()

# posMap Pfeile darstellen
func show_arrows():
	# wir nehmen ann dass die PosMap schon geladen ist
	var multi: MultiMesh = arrows.multimesh
	var scale = grid_size / 150
	
	multi.instance_count = grid_count_x * grid_count_y
	
	
	var half_gridsize = grid_size/ 2
	var index = 0
	
	for row in range(grid_count_y):
		for col in range(grid_count_x):
			var posValue = posMap.get_value(col, row)
			var pos: Vector2 = Vector2(grid_size.x * col, grid_size.y * row)
			pos.x += half_gridsize.x
			pos.y += half_gridsize.y
			
			#var trans: Transform2D = Transform2D(posValue, pos)
			var trans = arrowTransform.rotated(posValue)
			trans.origin = pos

			multi.set_instance_transform_2d(index, trans)
			index +=1


# ausgewaehlten Pfeil rotieren
func rotate_arrow(value: float):
	var col = current_grid_pos.x
	var row = current_grid_pos.y
	print("current_grid_pos: ", current_grid_pos)
	var index = (row * grid_count_x) + col
	print("index: ", index)
	if index >= posMap.count:
		return
	
	var trans = arrowTransform.rotated(value)

	# Pfeil drehen
	var half_gridsize = grid_size /2
	var pos: Vector2 = Vector2(grid_size.x * col, grid_size.y * row)
	pos.x += half_gridsize.x
	pos.y += half_gridsize.y
	trans.origin = pos
	arrows.multimesh.set_instance_transform_2d(index, trans)

	# Wert speichern
	posMap.set_value(value, col, row)


# Grid Position auf die geklickt worden ist ermitteln
func set_gridPos(pos: Vector2):
	if pos.x < 0 or pos.y < 0 or pos.x > texture_size.x or pos.y > texture_size.y:
		return
		
	var factor_x = grid_count_x / texture_size.x
	var factor_y = grid_count_y / texture_size.y
	
	# Aktuelle Position
	#current_grid_pos = Vector2(int(factor_x * pos.x), int(factor_y * pos.y))
	current_grid_pos = Vector2(int(pos.x / grid_size.x), int(pos.y / grid_size.y))
	print("curren_grid_pos: ", current_grid_pos)
	
	# Wert in Rotation anzeigen
	rotationBar.value = posMap.get_valuev(current_grid_pos)
	
	# markieren
	


# ===================
#   Signale
# -----------

# wenn ein Bild(Pfad) in das Fenster gedropt wird
func _on_files_dropped(files, _screen):
	print(files)
	# Bild laden
	load_ref_image(files[0])


# wenn sich die anzahl der Spalten ändert
func _on_grid_cols_value_changed(value):
	grid_count_x = int(value)
	read_size()



func _on_grid_rows_value_changed(value):
	grid_count_y = int(value)
	read_size()


# wenn Dateiname Ausgewählt
func _on_FileDialog_file_selected(path):
	if dialogMode == "save_posmap":
		posMap.save(path)
		print("PosValue: ", posMap.get_value(5, 5))
	elif dialogMode == "load_posmap":
		posMap.load(path)
		get_posMap_data()
		show_arrows()
		print("PosValue: ", posMap.get_value(5, 5))


# Posmap erstellen
func _on_create_button_pressed():
	create_posMap()



func _on_save_button_pressed():
	save_posMap()
	pass # Replace with function body.


func _on_load_button_pressed():
	load_posMap()
	pass # Replace with function body.




func _on_rotation_value_changed(value):
	rotate_arrow(value)
	pass # Replace with function body.
