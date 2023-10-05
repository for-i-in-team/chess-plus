class_name ChessInput

extends Node2D

@export var highlighter: PackedScene
var square: ChessSquareView
var board: ChessBoardView
var move_squares: Array[ChessBoard.Square]
var take_squares: Array[ChessBoard.Square]
var color : ChessPiece.PieceColor
var current_turn : ChessPiece.PieceColor
var moving: bool = false

func init(chess_board: ChessBoardView, _color:ChessPiece.PieceColor, _current_turn:ChessPiece.PieceColor, chess_square: ChessSquareView=null):
	board = chess_board
	color = _color
	current_turn = _current_turn
	set_square(chess_square)

	board.board.events.turn_started.connect_sig(func(_color):set_turn(_color))

func set_turn(_color:ChessPiece.PieceColor):
	current_turn = _color

func handle_selection(sq: ChessSquareView):
	if not moving:
		moving = true
		await(set_square(sq))
		moving = false
	

func set_square(sq : ChessSquareView):
	if sq == null:
		square = null
		move_squares = []
		take_squares = []
		for child in get_children():
			remove_child(child)
		return
	if current_turn == color and square != null and square.square.piece != null and square.square.piece.color == color:
		if sq.square in move_squares:
			await(board.board.move(square.square, sq.square))
		if sq.square in take_squares:
			await(board.board.take(square.square, sq.square))

	square = sq

	var piece : ChessPiece = square.square.piece
	move_squares = []
	take_squares = []
	if piece != null:
		for move in board.board.get_valid_moves(square.square):
			move_squares.append(move.to_square)
		for take in board.board.get_valid_takes(square.square):
			take_squares.append(take.to_square) 

	set_highlights()

func set_highlights():
	for child in get_children():
		remove_child(child)
	spawn_highlighter(square, Color.LIGHT_GREEN)
	for sq in move_squares:
		spawn_highlighter(board.get_square_view(sq),  Color.LIGHT_YELLOW)
	for sq in take_squares:
		spawn_highlighter(board.get_square_view(sq), Color.RED)

func spawn_highlighter(sq:ChessSquareView,_color:Color):
	var highlight = highlighter.instantiate()
	highlight.init(sq,_color)
	add_child(highlight)
