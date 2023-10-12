class_name ChessBoard

var size :Vector2
var board : Array[BoardRow] = []
var events : Events = Events.new()
var constraints:Array[GameConstraint] = []
var effects:Array[GameEffect] = []
var colors:Array[ChessPiece.PieceColor]
var current_turn : ChessPiece.PieceColor = ChessPiece.PieceColor.white

func _init(board_size:Vector2, _constraints:Array[GameConstraint] = [], _colors:Array[ChessPiece.PieceColor] = []):
	if len(_constraints) > 0:
		constraints = _constraints
	if len(_colors) > 0:
		colors = _colors
	else:
		colors = get_colors()
	for i in range(board_size.y):
		size = board_size
		board.append(BoardRow.new(i,size.x as int))
	events.color_lost.connect_sig(func(color):await(handle_color_loss(color)))

func next_turn():
	var index:int = colors.find(current_turn)
	assert(index >= 0, "Invalid color %s" % current_turn)
	index += 1
	if index >= colors.size():
		index = 0
	current_turn = colors[index]
	for col in board:
		for square in col.row:
			if square.piece != null:
				square.piece.turn_started(self, current_turn) 
	events.turn_started.emit([current_turn])

func handle_color_loss(color:ChessPiece.PieceColor):
	colors.erase(color)
	if len(colors) == 1:
		await(events.game_over.emit([colors[0]]))

func get_colors():
	var _colors:Array[ChessPiece.PieceColor] = []
	for row in board:
		for square in row.row:
			if square.piece != null and square.piece.color not in _colors:
				_colors.append(square.piece.color)
	return _colors

func add_effect(effect:GameEffect):
	effect.set_board(self)
	effects.append(effect)

func get_square(coordinates:Vector2):
	if coordinates.x < 0 or coordinates.x >= size.x or coordinates.y < 0 or coordinates.y >= size.y:
		return null
	else:
		# AUDIT Do we need to swap the rows to columns so that we can access
		return board[coordinates.y as int].row[coordinates.x as int]

func get_all_moves(color:ChessPiece.PieceColor) -> Array[ChessPiece.Move]:
	var moves:Array[ChessPiece.Move] = []
	for row in board:
		for square in row.row:
			if square.piece != null and square.piece.color == color:
				moves += get_valid_moves(square)
	return moves

func get_all_takes(color:ChessPiece.PieceColor) -> Array[ChessPiece.Take]:
	var takes:Array[ChessPiece.Take] = []
	for row in board:
		for square in row.row:
			if square.piece != null and square.piece.color == color:
				takes += get_valid_takes(square)
	return takes

func move(origin_square:ChessBoard.Square, target_square:ChessBoard.Square):
	var _move : ChessPiece.Move
	for m in get_valid_moves(origin_square):
		if m.to_square == target_square:
			_move = m
			break
	assert( _move != null, "Invalid move %s -> %s" % [origin_square.to_string(), target_square.to_string()])
	var piece:ChessPiece = origin_square.piece
	piece.move(self, _move)
	
	await(events.piece_moved.emit([_move]))
	next_turn()

func take(origin_square:ChessBoard.Square, destination_square:ChessBoard.Square):
	var takes :Array[ChessPiece.Take] = get_valid_takes(origin_square)
	var _take : ChessPiece.Take = null
	for t in takes:
		if t.to_square == destination_square:
			_take = t
			break
	assert( take != null, "Invalid move %s -> %s" % [origin_square.to_string(), destination_square.to_string()])
	origin_square.piece.take(self, _take)
	await(events.piece_taken.emit([_take]))
	next_turn()

func get_valid_moves(origin_square:ChessBoard.Square) -> Array[ChessPiece.Move]:
	return validate_moves(origin_square.piece.get_valid_moves(self, origin_square))

func get_valid_takes(origin_square:ChessBoard.Square)-> Array[ChessPiece.Take]:
	return validate_takes(origin_square.piece.get_valid_takes(self, origin_square))

func validate_moves(moves : Array[ChessPiece.Move])-> Array[ChessPiece.Move]:
	var valid:Array[ChessPiece.Move] = []
	var needs_state:bool = false
	for c in constraints:
		if c.requires_next_state:
			needs_state = true
			break
	for _move in moves:
		var next_state = null
		if needs_state:
			next_state = get_new_board_state_move(_move)
		var is_move_valid:bool = true
		for c in constraints:
			if not c.validate_move(self, _move, next_state):
				is_move_valid = false
				break
		if is_move_valid:
			valid.append(_move)
	return valid

func validate_takes(takes:Array[ChessPiece.Take])-> Array[ChessPiece.Take]:
	var valid:Array[ChessPiece.Take] = []
	var needs_state:bool = false
	for c in constraints:
		if c.requires_next_state:
			needs_state = true
			break
	for _take in takes:
		var next_state = null
		if needs_state:
			next_state = get_new_board_state_take(_take)
		var is_take_valid:bool = true
		for c in constraints:
			if not c.validate_take(self, _take, next_state):
				is_take_valid = false
				break
		if is_take_valid:
			valid.append(_take)
	return valid

func get_new_board_state_take(_take:ChessPiece.Take):
	var new_board = copy()
	var from_square : Square = new_board.get_square(_take.from_square.coordinates)
	var new_targets = []
	for sq in _take.targets:
		new_targets.append(new_board.get_square(sq.coordinates))
	var new_take = ChessPiece.Take.new(from_square.piece, from_square, new_board.get_square(_take.to_square.coordinates), [], new_targets)
	
	for sq in _take.traversed_squares:
		new_take.traversed_squares.append(new_board.get_square(sq.coordinates))
	new_take.from_square.piece.take(new_board, new_take)
	return new_board

func get_new_board_state_move(_move: ChessPiece.Move) -> ChessBoard:
	var new_board = copy()
	var new_move : ChessPiece.Move = ChessPiece.Move.new(_move.piece.copy(), new_board.get_square(_move.from_square.coordinates), new_board.get_square(_move.to_square.coordinates), [])
	for mv in _move.incidental:
		new_move.incidental.append(ChessPiece.Move.new(mv.piece, new_board.get_square(mv.from_square.coordinates), new_board.get_square(mv.to_square.coordinates), []))
	for sq in _move.traversed_squares:
		new_move.traversed_squares.append(new_board.get_square(sq.coordinates))
	new_move.from_square.piece.move(new_board, new_move)
	return new_board

func copy() -> ChessBoard:
	var new_board = ChessBoard.new(size, constraints)
	for effect in effects:
		new_board.effects.append(effect.copy(new_board))
	for row in board:
		var new_row = BoardRow.new(row.row[0].coordinates.y as int, row.row.size())
		for square in row.row:
			var new_square = Square.new(square.color, square.coordinates)
			if square.piece != null:
				new_square.piece = square.piece.copy()
			new_row.row[square.coordinates.x as int] = new_square
		new_board.board[row.row[0].coordinates.y as int] = new_row
	return new_board

class BoardRow:
	var row:Array[Square]
	func _init(row_num:int, row_length:int, ):
		for i in range(row_length):
			var color : ChessBoard.SquareColor = (ChessBoard.Black.new() as ChessBoard.SquareColor) if (i+row_num)%2 == 0 else ChessBoard.White.new()
			row.append(Square.new(color, Vector2(i,row_num)))

class Square:
	var color:ChessBoard.SquareColor
	var coordinates : Vector2
	var piece : ChessPiece

	func _init( square_color:ChessBoard.SquareColor, coord : Vector2):
		color  = square_color
		coordinates = coord

	func _to_string():
		return "Square: (%f,%f) %s"%[coordinates.x, coordinates.y, piece]


class SquareColor:
	var color: Color

class Black: 
	extends SquareColor 
	func _init():
		self.color = Color(0.15, 0.22, 0.51)

class White:
	extends SquareColor
	func _init():
		self.color = Color.WHITE
	
