class_name ChessPieceView

extends Node2D


var piece : ChessPiece

func init(chess_piece:ChessPiece):
	piece = chess_piece
	$sprite.texture = get_image(piece)
	$sprite.modulate = piece.color.color

func get_image(load_piece:ChessPiece) -> Texture:

	return load("res://resources/pieces/"+load_piece.name.to_lower() + ".png")
