class_name ChessBoardView
extends Node2D

@export var chess_square_node : PackedScene
@export var board_size : Vector2 = Vector2(8,8)
var board :ChessBoard

# Called when the node enters the scene tree for the first time.
func _ready():
	board = TraditionalPieces.get_traditional_board_setup()
	for row in board.board:
		for square in row.row:
			var square_view:ChessSquareView = chess_square_node.instantiate()
			square_view.init(square)
			add_child(square_view)
