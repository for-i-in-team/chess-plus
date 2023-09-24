class_name ChessInput

extends Node2D

@export var highlighter: PackedScene
var square: ChessSquareView
var board: ChessBoardView
var move_squares: Array[ChessBoard.Square]
var take_squares: Array[ChessBoard.Square]
var color : ChessPiece.PieceColor
var current_turn : ChessPiece.PieceColor

func init(chess_board: ChessBoardView, _color:ChessPiece.PieceColor, _current_turn:ChessPiece.PieceColor, chess_square: ChessSquareView=null):
	board = chess_board
	color = _color
	current_turn = _current_turn
	set_square(chess_square)

	board.board.events.turn_started.connect(func(color):set_turn(color))

func set_turn(color:ChessPiece.PieceColor):
	current_turn = color

func set_square(sq : ChessSquareView):
	if sq == null:
		square = null
		move_squares = []
		take_squares = []
		for child in get_children():
			remove_child(child)
		return
	
	if current_turn == color:
		if sq.square in move_squares:
			board.board.move(square.square, sq.square)
		if sq.square in take_squares:
			board.board.take(square.square, sq.square)

	square = sq

	var piece : ChessPiece = square.square.piece
	if piece == null:
		move_squares = []
		take_squares = []
	else:
		self.move_squares = board.board.get_valid_moves(square.square)
		self.take_squares = []
		for take in board.board.get_valid_takes(square.square):
			self.take_squares.append(take.to_square) 

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
