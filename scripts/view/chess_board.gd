class_name ChessBoardView
extends Node2D

@export var chess_square_node : PackedScene
@export var board_size : Vector2 = Vector2(8,8)
var board :ChessBoard

# Called when the node enters the scene tree for the first time.
func _ready():
	board = ChessBoard.new(board_size)
	for row in range(len(board.board)):
		for col in range(len(board.board[row].row)):
			var square:ChessSquareView = chess_square_node.instantiate()
			square.init(board.board[row].row[col],Vector2(col, row))
			add_child(square)
