class_name ChessSquareView

extends Sprite2D


var color:ChessBoard.SquareColor
var square : ChessBoard.Square

func init(chess_square:ChessBoard.Square):
	square = chess_square
	modulate = square.color.color
	position = square.coordinates * texture.get_width()*scale
