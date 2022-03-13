extends Sprite

# ================
#   Variablen
# ------------

# ================
#   Objekte
# ------------
var editor: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	editor = get_node("/root/Editor")
	pass # Replace with function body.

# Grid Zeichnen
func _draw():
	draw_grid()
	pass

#func _input(event):
#	if event is InputEventMouseButton:
#		if event.pressed and event.button_index == 1:
#			print("2 position: ", event.position)
#			print("2 global_position: ", event.global_position)
#			print("2 image local_position: ", get_local_mouse_position())
		

# Grid zeichnen
func draw_grid():
	# Gitter
	for col in range(0, editor.grid_count_x +1):
		var pos_x = col * editor.grid_size.x
		draw_line(Vector2(pos_x, 0), Vector2(pos_x, editor.texture_size.y), editor.grid_color)
	
	for row in range(0, editor.grid_count_y +1):
		var pos_y = row * editor.grid_size.y
		draw_line(Vector2(0, pos_y), Vector2(editor.texture_size.x, pos_y), editor.grid_color)
