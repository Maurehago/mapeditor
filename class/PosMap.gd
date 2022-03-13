extends Object

class_name PosMap

# ===================
#    Variablen
# -------------

var col_count: int = 0
var row_count: int = 0
var list: Array = []
var count: int = 0

# ======================
#   Godot Funktionen
# -------------------


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# ======================
#   Eigene Funktionen
# ---------------------

# Inhalt groesse ändern
func set_size(cols: int, rows: int):
	col_count = cols
	row_count = rows
	
	# groesse aendern
	count = cols * rows
	list.resize(count)


func set_sizev(size: Vector2):
	set_size(size.x, size.y)

	
# Inhalt groesse lesen
func get_size() -> Vector2:
	return Vector2(col_count, row_count)
	

# Alle Werte befuellen
func fill_values(value: int):
	for cell in range(count):
		list[cell] = value


# Wert setzen
func set_value(value: float, col: int, row: int):
	var index = (row * col_count) + col
	if index >= 0 and index < count:
		list[index] = value

func set_valuev(value: float, pos: Vector2):
	set_value(value, pos.x, pos.y)
	

# Wert lesen
func get_value(col: float, row: int) -> float:
	var index = (row * col_count) + col
	if index >= 0 and index < count:
		return list[index]
	else:
		return 0.0


func get_valuev(pos: Vector2) -> float:
	return get_value(pos.x, pos.y)


# Speichern
func save(fileName: String):
	var file = File.new()
	file.open(fileName, File.WRITE)
	
	
	# Positionen
	file.store_64(col_count)
	file.store_64(row_count)
	file.store_64(count)
	
	# Werte
	for index in range(count):
		file.store_float(list[index])
	
	# schliessen
	file.close()


# Laden
func load(fileName: String):
	var file = File.new()
	file.open(fileName, File.READ)
	
	# Positionen
	col_count = file.get_64()
	row_count = file.get_64()
	count = file.get_64()
		
	# Werte
	list.resize(count)
	for index in range(count):
		list[index] = file.get_float()

	file.close()
	
