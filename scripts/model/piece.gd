class_name ChessPiece

class PieceModifier:
	func move(_piece:ChessPiece, _board: ChessBoard, _move:Move):
		return _move

	func get_valid_moves(_piece:ChessPiece, _board: ChessBoard, _current_square:ChessBoard.Square, moves:Array[Move]) -> Array[Move]:
		return moves

	func take(_piece:ChessPiece, _board: ChessBoard, _take:Take):
		return _take

	func get_valid_takes(_piece:ChessPiece, _board: ChessBoard, _current_square:ChessBoard.Square, takes:Array[Take]) -> Array[Take]:
		return takes

	func get_take_for_square(_piece:ChessPiece, _board: ChessBoard, _current_square:ChessBoard.Square, _target_square:ChessBoard.Square, existing_take:Take) -> Take:
		return existing_take

	func turn_started(_piece:ChessPiece, _board: ChessBoard, _turn_color:PieceColor):
		pass

	func copy():
		return self

	func equals(other:PieceModifier):
		return other.get_script() == get_script()
	
class TurnOption:

	func apply_to_board(_board:ChessBoard):
		assert(false, "TurnOption.apply_to_board not implemented")

	func convert_for_board(_board:ChessBoard) -> TurnOption:
		assert(false, "TurnOption.convert_for_board not implemented")
		return null

	func copy_on_board(_board:ChessBoard) -> ChessBoard:
		assert(false, "TurnOption.copy_on_board not implemented")
		return null

class Take:
	extends TurnOption

	var piece : ChessPiece
	var from_square : ChessBoard.Square
	var to_square : ChessBoard.Square
	var targets : Array[ChessBoard.Square]
	var traversed_squares : Array[ChessBoard.Square]
	var taken_pieces : Array[ChessPiece]

	func _init(_piece:ChessPiece,_from_square: ChessBoard.Square, _to_square: ChessBoard.Square, _traversed_squares:Array[ChessBoard.Square], _targets : Array[ChessBoard.Square]):
		self.piece = _piece
		self.from_square = _from_square
		self.to_square = _to_square
		self.targets = _targets
		self.traversed_squares = _traversed_squares
		for sq in self.targets:
			if sq.piece != null:
				self.taken_pieces.append(sq.piece)

	func get_value():
		var value = 0
		for target in targets:
			if target.piece != null:
				value += target.piece.point_value
		return value

	func apply_to_board(board:ChessBoard):
		await(board.direct_take(self))

	func convert_for_board(board:ChessBoard):
		var new_take = Take.new(piece, from_square, to_square, [], [])
		new_take.from_square = board.get_square(from_square.coordinates)
		new_take.to_square = board.get_square(to_square.coordinates)
		new_take.traversed_squares.clear()
		for square in traversed_squares:
			new_take.traversed_squares.append(board.get_square(square.coordinates))
		new_take.targets.clear()
		for square in targets:
			new_take.targets.append(board.get_square(square.coordinates))
		return new_take

	func copy_on_board(board:ChessBoard):
		return await(board.get_new_board_state_take(self))

class Move:
	extends TurnOption

	var piece : ChessPiece
	var from_square : ChessBoard.Square
	var to_square : ChessBoard.Square
	var incidental : Array[Move]
	var traversed_squares : Array[ChessBoard.Square]

	func _init(_piece:ChessPiece, _from_square: ChessBoard.Square, _to_square: ChessBoard.Square, _traversed_squares:Array[ChessBoard.Square], _incidental : Array[Move] = []):
		piece = _piece
		from_square = _from_square
		to_square = _to_square
		incidental = _incidental
		self.traversed_squares = _traversed_squares

	func apply_to_board(board:ChessBoard):
		await(board.direct_move(self))

	func convert_for_board(board:ChessBoard):
		var new_move = Move.new(piece, from_square, to_square, [], [])
		new_move.from_square = board.get_square(from_square.coordinates)
		new_move.to_square = board.get_square(to_square.coordinates)
		new_move.traversed_squares.clear()
		for square in traversed_squares:
			new_move.traversed_squares.append(board.get_square(square.coordinates))
		new_move.incidental.clear()
		for move in incidental:
			new_move.incidental.append(move.convert_for_board(board))
		return new_move

	func copy_on_board(board:ChessBoard):
		return await(board.get_new_board_state_move(self))

class PieceColor:
	var name : String
	var color : Color
	var move_direction : Vector2

	static var white = PieceColor.new("White", Color.WHITE, Vector2(0, 1))
	static var black = PieceColor.new("Black", Color(0.13,0.14,0.18), Vector2(0, -1))

	static var colors = [white, black]

	func _init(_name, _color, _move_direction):
		name = _name
		color = _color
		move_direction = _move_direction

	func get_perpendicular_direction():
		return Vector2(move_direction.y, move_direction.x)

	func on_deserialize():
		for piece_color in colors:
			if piece_color.name == name:
				return piece_color
		return self


var id : int
var name : String
var color : PieceColor
var point_value : float
var move_patterns:Array[PieceMovement.MovePattern]
var take_patterns:Array[PieceMovement.TakePattern]
var modifiers:Array[PieceModifier]

func _init(_name, _color:PieceColor, _point_value:float, _move_patterns:Array[PieceMovement.MovePattern], _take_patterns:Array[PieceMovement.TakePattern], _modifiers:Array[PieceModifier] = []):
	id = self.get_instance_id()
	name = _name
	color = _color
	point_value = _point_value
	move_patterns = _move_patterns
	take_patterns = _take_patterns
	modifiers = _modifiers

func move(_board: ChessBoard, _move:Move):
	for modifier in modifiers:
		_move = modifier.move(self, _board, _move)
	for pattern in move_patterns:
		pattern.move(self, _board, _move)
	for pattern in take_patterns:
		pattern.move(self, _board, _move)
	_move.from_square.piece = null
	_move.to_square.piece = self
	for incidental_move in _move.incidental:
		var piece: ChessPiece = incidental_move.from_square.piece
		incidental_move.from_square.piece = null
		incidental_move.to_square.piece = piece

func get_valid_moves(board: ChessBoard, current_square:ChessBoard.Square) -> Array[Move]:
	var moves : Array[Move] = []
	
	for pattern in move_patterns:
		moves.append_array(pattern.get_valid_moves(self, board, current_square))
	
	for modifier in modifiers:
		moves = modifier.get_valid_moves(self, board, current_square, moves)

	return moves

func take(_board:ChessBoard, _take:Take):
	for modifier in modifiers:
		_take = modifier.take(self, _board, _take)
	for pattern in move_patterns:
		pattern.take(self, _board, _take)
	for pattern in take_patterns:
		pattern.take(self, _board, _take)
	_take.from_square.piece = null
	for target_square in _take.targets:
		target_square.piece = null
	_take.to_square.piece = self
	
func get_valid_takes(board: ChessBoard, current_square:ChessBoard.Square) -> Array[Take]:
	var takes : Array[Take] = []

	for pattern in take_patterns:
		takes.append_array(pattern.get_valid_takes(self, board, current_square))

	for modifier in modifiers:
		takes = modifier.get_valid_takes(self, board, current_square, takes)

	return takes

func get_take_for_square(_board: ChessBoard, current_square:ChessBoard.Square, target_square:ChessBoard.Square, traversed: Array[ChessBoard.Square]) -> Take:
	var targets:Array[ChessBoard.Square] = []
	if target_square.piece != null:
		targets.append(target_square)
	var _take : Take = Take.new(self, current_square, target_square, traversed, targets)
	
	for modifier in modifiers:
		_take = modifier.get_take_for_square(self, _board, current_square, target_square, _take)
	return _take

func turn_started(board:ChessBoard, turn_color:PieceColor):
	for modifier in modifiers:
		modifier.turn_started(self, board, turn_color)

func get_modifier(mod_type:GDScript):
	for modifier in modifiers:
		if is_instance_of(modifier, mod_type):
			return modifier
	return null

func _orthogonal_where(board: ChessBoard, current_square: ChessBoard.Square, condition : Callable) -> Array[ChessBoard.Square]:
	var valid:Array[ChessBoard.Square] = []
	var directions:Array[Vector2] = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
	for direction in directions:
		valid += _direction_where(board, current_square, direction, condition)
	return valid

func _diagonal_where(board: ChessBoard, current_square: ChessBoard.Square, condition : Callable) -> Array[ChessBoard.Square]:
	var valid:Array[ChessBoard.Square] = []
	var directions:Array[Vector2] = [Vector2(1,1), Vector2(-1,1), Vector2(1,-1), Vector2(-1,-1)]
	for direction in directions:
		valid += _direction_where(board, current_square, direction, condition)
	return valid

func _direction_where(board:ChessBoard, current_square: ChessBoard.Square, direction:Vector2, condition : Callable) -> Array[ChessBoard.Square]:
	var valid:Array[ChessBoard.Square] = []
	var new_square : ChessBoard.Square = board.get_square(current_square.coordinates + direction)
	while new_square != null and condition.call(new_square):
		valid.append(new_square)
		new_square = board.get_square(new_square.coordinates + direction)
	return valid

func instantiate(_name,_color,_point_value):
	return ChessPiece.new(_name, _color, _point_value, [], [])

func copy() -> ChessPiece:
	var piece = instantiate(name, color, point_value)

	for pattern in move_patterns:
		piece.move_patterns.append(pattern.copy())

	for pattern in take_patterns:
		piece.take_patterns.append(pattern.copy())

	for modifier in modifiers:
		piece.modifiers.append(modifier.copy())

	return piece
	

func _to_string():
	return color.name + " " + name

func equals(other:ChessPiece):
	if other.get_script() == get_script() and name == other.name and color == other.color and point_value == other.point_value:
		for modifier in modifiers:
			var found = false
			for other_modifier in other.modifiers:
				if modifier.equals(other_modifier):
					found = true
					break
			if not found:
				return false
		
		for take_pattern in take_patterns:
			var found = false
			for other_take_pattern in other.take_patterns:
				if take_pattern.equals(other_take_pattern):
					found = true
					break
			if not found:
				return false
		
		for move_pattern in move_patterns:
			var found = false
			for other_move_pattern in other.move_patterns:
				if move_pattern.equals(other_move_pattern):
					found = true
					break
			if not found:
				return false
		return true
		
	return false
