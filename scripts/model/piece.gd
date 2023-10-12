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
	

class Take:
	var piece : ChessPiece
	var from_square : ChessBoard.Square
	var to_square : ChessBoard.Square
	var targets : Array[ChessBoard.Square]
	var traversed_squares : Array[ChessBoard.Square]

	func _init(_piece:ChessPiece,_from_square: ChessBoard.Square, _to_square: ChessBoard.Square, _traversed_squares:Array[ChessBoard.Square], _targets : Array[ChessBoard.Square]):
		self.piece = _piece
		self.from_square = _from_square
		self.to_square = _to_square
		self.targets = _targets
		self.traversed_squares = _traversed_squares

	func get_value():
		var value = 0
		for target in targets:
			if target.piece != null:
				value += target.piece.point_value
		return value

class Move:
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

class PieceColor:
	var name : String
	var color : Color
	var move_direction : Vector2

	static var white = PieceColor.new("White", Color.WHITE, Vector2(0, 1))
	static var black = PieceColor.new("Black", Color(0.13,0.14,0.18), Vector2(0, -1))

	func _init(_name, _color, _move_direction):
		name = _name
		color = _color
		move_direction = _move_direction

	func get_perpendicular_direction():
		return Vector2(move_direction.y, move_direction.x)


var name : String
var color : PieceColor
var point_value : float
var move_patterns:Array[PieceMovement.MovePattern]
var take_patterns:Array[PieceMovement.TakePattern]
var modifiers:Array[PieceModifier]

func _init(_name, _color:PieceColor, _point_value:float, _move_patterns:Array[PieceMovement.MovePattern], _take_patterns:Array[PieceMovement.TakePattern], _modifiers:Array[PieceModifier] = []):
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
	var _take : Take = Take.new(self, current_square, target_square, traversed, [])
	if target_square.piece != null:
		_take.targets.append(target_square)
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
