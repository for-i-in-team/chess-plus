class_name ChessSquare

extends Sprite2D


var color:ChessBoard.SquareColor
var coords:Vector2
var piece

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(square_coords:Vector2, square_color:ChessBoard.SquareColor):
	color  = square_color
	coords = square_coords
	modulate = color.color
	position = coords * texture.get_width()*scale
