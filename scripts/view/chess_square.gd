class_name ChessSquareView

extends Node2D

@export var piece_scene : PackedScene
var color:ChessBoard.SquareColor
var square : ChessBoard.Square

func init(chess_square:ChessBoard.Square):
	square = chess_square
	$sprite.modulate = square.color.color
	position = square.coordinates * $sprite.texture.get_width()*$sprite.scale
	if square.piece != null:
		var piece = piece_scene.instantiate()
		piece.init(square.piece)
		add_child(piece)
