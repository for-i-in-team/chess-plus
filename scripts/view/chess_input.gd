class_name ChessInput

extends Node2D

@export var highlighter: PackedScene
var square: ChessSquareView
var board: ChessBoardView
var move_squares: Array[ChessBoard.Square]
var take_squares: Array[ChessBoard.Square]

func init(chess_board: ChessBoardView, chess_square: ChessSquareView=null):
	board = chess_board
	set_square(chess_square)

func set_square(sq : ChessSquareView):
	if sq == null:
		square = null
		move_squares = []
		take_squares = []
		for child in get_children():
			remove_child(child)
		return
	
	if sq.square in move_squares:
		square.square.piece.move(board.board, square.square, sq.square)
	if sq.square in take_squares:
		square.square.piece.take(board.board, square.square, sq.square)

	square = sq

	var piece : ChessPiece = square.square.piece
	if piece == null:
		move_squares = []
		take_squares = []
	else:
		self.move_squares = piece.get_valid_moves(board.board, square.square)
		self.take_squares = piece.get_valid_takes(board.board, square.square)

	set_highlights()

func set_highlights():
	for child in get_children():
		remove_child(child)
	spawn_highlighter(square, Color.LIGHT_GREEN)
	for sq in move_squares:
		spawn_highlighter(board.get_square_view(sq),  Color.LIGHT_YELLOW)
	for sq in take_squares:
		spawn_highlighter(board.get_square_view(sq), Color.RED)

func spawn_highlighter(sq:ChessSquareView,color:Color):
	var highlight = highlighter.instantiate()
	highlight.init(sq,color)
	add_child(highlight)
