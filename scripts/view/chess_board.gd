class_name ChessBoardView
extends Node2D

@export var chess_square_node : PackedScene
@export var board_size : Vector2 = Vector2(8,8)
var board : Array[BoardRow] = []

class BoardRow:
	var row:Array[ChessSquareView]
	func _init(row_num:int, board_size:Vector2, chess_square_node:PackedScene, ):
		for i in range(board_size.x):
			var color : ChessBoard.SquareColor = (ChessBoard.Black.new() as ChessBoard.SquareColor) if (i+row_num)%2 == 0 else ChessBoard.White.new()
			var square:ChessSquareView = chess_square_node.instantiate()
			square.init(ChessBoard.ChessSquare.new(color),Vector2(i,row_num))
			row.append(square)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(board_size.y):
		board.append(BoardRow.new(i,board_size, chess_square_node))
		for square in board[i].row:
			add_child(square)
