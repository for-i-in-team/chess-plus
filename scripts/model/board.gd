

class_name ChessBoard

var size :Vector2
var board : Array[BoardRow] = []
var events : Events = Events.new()
var constraints:Array[GameConstraint] = []

func _init(board_size:Vector2, _constraints:Array[GameConstraint] = []):
	if len(_constraints) > 0:
		constraints = _constraints
	for i in range(board_size.y):
		size = board_size
		board.append(BoardRow.new(i,size.x as int))

func get_square(coordinates:Vector2):
	if coordinates.x < 0 or coordinates.x >= size.x or coordinates.y < 0 or coordinates.y >= size.y:
		return null
	else:
		# AUDIT Do we need to swap the rows to columns so that we can access
		return board[coordinates.y as int].row[coordinates.x as int]

func move(origin_square:ChessBoard.Square, target_square:ChessBoard.Square):
	assert( target_square in origin_square.piece.get_valid_moves(self, origin_square), "Invalid move %s -> %s" % [origin_square.to_string(), target_square.to_string()])
	var piece:ChessPiece = origin_square.piece
	piece.move(self, origin_square, target_square)

	events.piece_moved.emit(piece, origin_square, target_square)

func take(origin_square:ChessBoard.Square, destination_square:ChessBoard.Square):
	var takes :Array[ChessPiece.Take] = get_valid_takes(origin_square)
	var _take : ChessPiece.Take = null
	for t in takes:
		if t.to_square == destination_square:
			_take = t
			break
	assert( take != null, "Invalid move %s -> %s" % [origin_square.to_string(), destination_square.to_string()])
	origin_square.piece.take(_take)
	
	events.piece_taken.emit(_take)

func get_valid_moves(origin_square:ChessBoard.Square):
	return validate_moves(origin_square, origin_square.piece.get_valid_moves(self, origin_square))

func get_valid_takes(origin_square:ChessBoard.Square):
	return validate_takes(origin_square.piece.get_valid_takes(self, origin_square))

func validate_moves(origin_square:ChessBoard.Square, destination_squares:Array[ChessBoard.Square]):
	# TODO Work out how to handle other illegal moves (e.g. revealed check, also need to work out how to test checkmate)
	var valid:Array[ChessBoard.Square] = []
	var needs_state:bool = false
	for c in constraints:
		if c.requires_next_state:
			needs_state = true
			break
	for square in destination_squares:
		var next_state = null
		if needs_state:
			next_state = get_new_board_state_move(origin_square, square)
		var is_move_valid:bool = true
		for c in constraints:
			if not c.validate_move(self, origin_square, square, next_state):
				is_move_valid = false
				break
		if is_move_valid:
			valid.append(square)
	return valid

func validate_takes(takes:Array[ChessPiece.Take]):
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
	var new_take = ChessPiece.Take.new(new_board.get_square(_take.from_square.coordinates), new_board.get_square(_take.to_square.coordinates), [])
	for sq in _take.targets:
		new_take.targets.append(new_board.get_square(sq.coordinates))
	new_take.from_square.piece.take(new_take)
	return new_board

func get_new_board_state_move(origin_square:ChessBoard.Square, destination_square:ChessBoard.Square):
	var new_board = copy()
	var origin = new_board.get_square(origin_square.coordinates)
	var destination = new_board.get_square(destination_square.coordinates)
	origin.piece.move(new_board, origin, destination)
	return new_board

func copy():
	var new_board = ChessBoard.new(size, constraints)
	for row in board:
		var new_row = BoardRow.new(row.row[0].coordinates.y as int, row.row.size())
		for square in row.row:
			var new_square = Square.new(square.color, square.coordinates)
			if square.piece != null:
				new_square.piece = square.piece.copy()
			new_row.row.append(new_square)
		new_board.board.append(new_row)
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
	
