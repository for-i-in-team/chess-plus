class_name ChessSquareView

extends Sprite2D


var color:ChessBoard.SquareColor
var square : ChessBoard.ChessSquare

func init(chess_square:ChessBoard.ChessSquare, coords : Vector2):
	square = chess_square
	modulate = square.color.color
	position = coords * texture.get_width()*scale
