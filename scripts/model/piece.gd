class_name ChessPiece



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

func move(board: ChessBoard, current_square:ChessBoard.Square, target_square:ChessBoard.Square):
	assert( target_square in get_valid_moves(board, current_square), "Invalid move %s -> %s" % [current_square.to_string(), target_square.to_string()])
	current_square.piece = null
	target_square.piece = self
	board.events.piece_moved.emit(self, current_square, target_square)

func get_valid_moves(board: ChessBoard, current_square:ChessBoard.Square) -> Array[ChessBoard.Square]:
	assert(false, "get_valid_moves not implemented " + current_square.to_string() + board.to_string())
	return []

func take(board: ChessBoard, current_square:ChessBoard.Square, target_square:ChessBoard.Square):
	assert( target_square in get_valid_takes(board, current_square), "Invalid move %s -> %s" % [current_square.to_string(), target_square.to_string()])
	current_square.piece = null
	target_square.piece = self
	
	board.events.piece_taken.emit(current_square, target_square, self, target_square.piece)

func get_valid_takes(board: ChessBoard, current_square:ChessBoard.Square) -> Array[ChessBoard.Square]:
	assert(false, "get_valid_takes not implemented " + current_square.to_string() + board.to_string())
	return [current_square]

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

func _to_string():
	return color.name + " " + name
