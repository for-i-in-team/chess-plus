class_name ChessPiece

class Take:
	var from_square : ChessBoard.Square
	var to_square : ChessBoard.Square
	var targets : Array[ChessBoard.Square]

	func _init(_from_square: ChessBoard.Square, _to_square: ChessBoard.Square, _targets : Array[ChessBoard.Square]):
		self.from_square = _from_square
		self.to_square = _to_square
		self.targets = _targets

class Move:
	var from_square : ChessBoard.Square
	var to_square : ChessBoard.Square
	var incidental : Array[Move]

	func _init(_from_square: ChessBoard.Square, _to_square: ChessBoard.Square, _incidental : Array[Move] = []):
		from_square = _from_square
		to_square = _to_square
		incidental = _incidental

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

const ALL_DIRECTIONS : Array[Vector2] =  [Vector2(1,1), Vector2(-1,1), Vector2(1,-1), Vector2(-1,-1),Vector2(0,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,0)]

var name : String
var color : PieceColor
var point_value : float

func _init(_name, _color, _point_value):
	name = _name
	color = _color
	point_value = _point_value

func move(_board: ChessBoard, _move:Move):
	_move.from_square.piece = null
	_move.to_square.piece = self
	for incidental_move in _move.incidental:
		var piece: ChessPiece = incidental_move.from_square.piece
		incidental_move.from_square.piece = null
		incidental_move.to_square.piece = piece

func get_valid_moves(board: ChessBoard, current_square:ChessBoard.Square) -> Array[Move]:
	assert(false, "get_valid_moves not implemented " + current_square.to_string() + board.to_string())
	return []

func take(_board:ChessBoard, _take:Take):
	_take.from_square.piece = null
	for target_square in _take.targets:
		target_square.piece = null
	_take.to_square.piece = self
	
func get_valid_takes(board: ChessBoard, current_square:ChessBoard.Square) -> Array[Take]:
	assert(false, "get_valid_takes not implemented " + current_square.to_string() + board.to_string())
	return []

func get_take_for_square(_board: ChessBoard, current_square:ChessBoard.Square, target_square:ChessBoard.Square) -> Take:
	return Take.new(current_square, target_square, [target_square])

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

func test_in_direction(board: ChessBoard, start: ChessBoard.Square, direction: Vector2, condition : Callable) -> ChessBoard.Square:
	## Returns the first square in the given direction that satisfies the condition. Returns null if no such square exists
	var new_square : ChessBoard.Square = board.get_square(start.coordinates + direction)
	while new_square != null and !condition.call(new_square):
		new_square = board.get_square(new_square.coordinates + direction)
	return new_square

func copy() -> ChessPiece:
	return self

func _to_string():
	return color.name + " " + name
