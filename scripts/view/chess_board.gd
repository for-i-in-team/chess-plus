class_name ChessBoardView
extends Node2D

@export var chess_square_node : PackedScene
@export var board_size : Vector2 = Vector2(8,8)
@export var input : ChessInput
var board :ChessBoard

# Called when the node enters the scene tree for the first time.
func _ready():
	board = TraditionalPieces.get_traditional_board_setup()
	for row in board.board:
		for square in row.row:
			var square_view:ChessSquareView = chess_square_node.instantiate()
			square_view.init(self, square)
			add_child(square_view)
			square_view.square_selected.connect(input.set_square)
	input.init(self)


	board.events.color_lost.connect(func(color:ChessPiece.PieceColor):print("color lost: " + color.name))

func get_square_view(square:ChessBoard.Square) -> ChessSquareView:
	for child in get_children():
		if child is ChessSquareView:
			var square_view:ChessSquareView = child as ChessSquareView
			if square_view.square == square:
				return square_view
	return null
