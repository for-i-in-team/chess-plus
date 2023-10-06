class_name TraditionalPieces



class Pawn:
	extends ChessPiece

	var has_moved : bool = false
	var en_passantable_coords : Array[ChessBoard.Square] = []

	func _init(_color:ChessPiece.PieceColor):
		super._init("Pawn", _color, 1, [PieceMovement.Pattern.new([_color.move_direction],1)], [])

	func move(board: ChessBoard, _move:ChessPiece.Move):
		await(super.move(board, _move))
		if (_move.from_square.coordinates - _move.to_square.coordinates).length() > 1:
			var en_passantable_coord :Vector2 = _move.to_square.coordinates - color.move_direction
			en_passantable_coords.append(board.get_square(en_passantable_coord))
		has_moved = true

	func take(board:ChessBoard, _take:ChessPiece.Take):
		await(super.take(board, _take))
		has_moved = true

	func get_valid_moves(board: ChessBoard, current_square: ChessBoard.Square) -> Array[ChessPiece.Move]:
		var valid:Array[ChessPiece.Move] = super.get_valid_moves(board,current_square)
		if !has_moved:
			var new_square:ChessBoard.Square = board.get_square(current_square.coordinates + color.move_direction * 2)
			if new_square != null and new_square.piece == null:
				valid.append(ChessPiece.Move.new(self, current_square,new_square))

		return valid

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square) -> Array[ChessPiece.Take]:
		var take_squares : Array[ChessBoard.Square] = [
			board.get_square(current_square.coordinates + color.move_direction + color.get_perpendicular_direction()),
			board.get_square(current_square.coordinates + color.move_direction - color.get_perpendicular_direction())
		]
		var valid_takes : Array[ChessPiece.Take] = []
		for square in take_squares:
			if square != null:
				var square_take : Take = get_take_for_square(board, current_square, square)
				if square_take.targets.size() > 0:
					valid_takes.append(square_take)

		return valid_takes

	func get_take_for_square(board:ChessBoard, current_square:ChessBoard.Square, target_square:ChessBoard.Square):
		var _take = ChessPiece.Take.new(self, current_square, target_square, [])
		if target_square.piece != null:
			_take.targets.append(target_square)
		
		for row in board.board:
			for ep_square in row.row:
				if ep_square.piece != null and ep_square.piece.color != color and ep_square.piece.get("en_passantable_coords") != null:
					var pawn : ChessPiece = ep_square.piece
					if target_square in pawn.en_passantable_coords:
						_take.targets.append(ep_square)
		return _take

	func on_turn_start(turn_color: ChessPiece.PieceColor):
		if turn_color == color:
			en_passantable_coords = []

	func copy() -> ChessPiece:
		var new_pawn : Pawn = Pawn.new(color)
		new_pawn.has_moved = has_moved
		new_pawn.en_passantable_coords = en_passantable_coords
		return new_pawn
			
class Rook:
	extends ChessPiece
	
	var has_moved : bool = false

	func _init(_color:ChessPiece.PieceColor):
		super._init("Rook", _color, 5, [PieceMovement.Pattern.new(PieceMovement.Direction.ORTHOGONAL)], [])

	func move(board: ChessBoard, _move:ChessPiece.Move):
		await(super.move(board, _move))
		has_moved = true

	func take(board:ChessBoard, _take:ChessPiece.Take):
		await(super.take(board, _take))
		has_moved = true

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square) -> Array[ChessPiece.Take]:
		var valid : Array[ChessPiece.Take] = []
		for direction in PieceMovement.Direction.ORTHOGONAL:
			var square = test_in_direction(board, current_square, direction, func(square:ChessBoard.Square): return square.piece != null)
			if square != null and square.piece.color != color:
				valid.append(get_take_for_square(board, current_square, square))
		return valid
		
	func copy() -> ChessPiece:
		var new_rook : Rook = Rook.new(color)
		new_rook.has_moved = has_moved
		return new_rook

class Bishop:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Bishop", _color, 3, [PieceMovement.Pattern.new(PieceMovement.Direction.DIAGONAL)], [])

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square) -> Array[ChessPiece.Take]:
		var valid : Array[ChessPiece.Take] = []
		for direction in PieceMovement.Direction.DIAGONAL:
			var square = test_in_direction(board, current_square, direction, func(square:ChessBoard.Square): return square.piece != null)
			if square != null and square.piece.color != color:
				valid.append(get_take_for_square(board, current_square, square))
		return valid

	func copy() -> ChessPiece:
		return Bishop.new(color)


class Knight:
	extends ChessPiece

	const KNIGHT_DIRECTIONS:Array[Vector2] = [Vector2(1,2), Vector2(-1,2), Vector2(1,-2), Vector2(-1,-2), Vector2(2,1), Vector2(-2,1), Vector2(2,-1), Vector2(-2,-1)]

	func _init(_color:ChessPiece.PieceColor):
		super._init("Knight", _color, 3, [PieceMovement.Pattern.new(KNIGHT_DIRECTIONS, 1)], [])

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square) -> Array[ChessPiece.Take]:
		var valid : Array[ChessPiece.Take] = []
		for direction in KNIGHT_DIRECTIONS:
			var square = board.get_square(current_square.coordinates + direction)
			if square != null and square.piece != null and square.piece.color != color:
				valid.append(get_take_for_square(board, current_square, square))
		return valid

	func copy() -> ChessPiece:
		return Knight.new(color)


class Queen:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Queen", _color, 8, [PieceMovement.Pattern.new(PieceMovement.Direction.DIAGONAL),PieceMovement.Pattern.new(PieceMovement.Direction.ORTHOGONAL)], [])

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square)-> Array[ChessPiece.Take]:
		var valid : Array[ChessPiece.Take] = []
		for direction in PieceMovement.Direction.ALL:
			var square = test_in_direction(board, current_square, direction, func(square:ChessBoard.Square): return square.piece != null)
			if square != null and square.piece.color != color:
				valid.append(get_take_for_square(board, current_square, square))
		return valid

	func copy() -> ChessPiece:
		return Queen.new(color)

class King:
	extends ChessPiece

	var has_moved : bool = false

	func _init(_color:ChessPiece.PieceColor):
		super._init("King", _color, 0, [PieceMovement.Pattern.new(PieceMovement.Direction.DIAGONAL, 1),PieceMovement.Pattern.new(PieceMovement.Direction.ORTHOGONAL, 1)], [])
	
	func move(board: ChessBoard, _move:Move):
		await(super.move(board, _move))
		has_moved = true

	func take(board:ChessBoard, _take:ChessPiece.Take):
		await(super.take(board, _take))
		has_moved = true

	func get_valid_moves(board: ChessBoard, current_square: ChessBoard.Square) -> Array[ChessPiece.Move]:
		var valid : Array[ChessPiece.Move] = super.get_valid_moves(board, current_square)
		if !has_moved:
			for direction in [Vector2(-1,0), Vector2(1,0)]:
				var _move : ChessPiece.Move = get_castle_move(board, current_square, direction)
				if _move != null:
					valid.append(_move)
		return valid

	func get_castle_move(board:ChessBoard, current_square:ChessBoard.Square, direction:Vector2):
		var to_square:ChessBoard.Square = board.get_square(current_square.coordinates + direction * 2)
		var next_piece_square = test_in_direction(board, current_square, direction, func(square:ChessBoard.Square): return square.piece != null)
		if next_piece_square != null and next_piece_square.piece is Rook and !next_piece_square.piece.has_moved and next_piece_square.piece.color == color:
			var threat_squares : Array[Vector2] = [current_square.coordinates,current_square.coordinates + direction, current_square.coordinates, current_square.coordinates + 2*direction]
			for square in threat_squares:
				if is_in_check(board, board.get_square(square)):
					return null
			var incidental = ChessPiece.Move.new(next_piece_square.piece, next_piece_square, board.get_square(to_square.coordinates - direction))
			return ChessPiece.Move.new(self, current_square, to_square, [incidental])
		return null

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square)->Array[ChessPiece.Take]:
		var valid : Array[ChessPiece.Take] = []
		for direction in PieceMovement.Direction.ALL:
			var square = board.get_square(current_square.coordinates + direction)
			if square != null and square.piece != null and square.piece.color != color:
				valid.append(get_take_for_square(board, current_square, square))
		return valid

	func is_in_check(board:ChessBoard, current_square:ChessBoard.Square) -> bool:
		for row in board.board:
			for square in row.row:
				if square.piece != null and square.piece.color != color:
					var valid_takes = square.piece.get_valid_takes(board, square)
					for _take in valid_takes:
						if _take.targets.find(current_square) != -1:
							return true
		return false
	
	func copy() -> ChessPiece:
		var new_king : King = King.new(color)
		new_king.has_moved = has_moved
		return new_king


static func lay_out_traditional_board(board:ChessBoard):
	# Pawns
	for i in range(8):
		board.get_square(Vector2(i,6)).piece = Pawn.new(ChessPiece.PieceColor.black)
		board.get_square(Vector2(i,1)).piece = Pawn.new(ChessPiece.PieceColor.white)

	# Rooks
	board.get_square(Vector2(0,7)).piece = Rook.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(7,7)).piece = Rook.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(0,0)).piece = Rook.new(ChessPiece.PieceColor.white)
	board.get_square(Vector2(7,0)).piece = Rook.new(ChessPiece.PieceColor.white)

	# Knights
	board.get_square(Vector2(1,7)).piece = Knight.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(6,7)).piece = Knight.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(1,0)).piece = Knight.new(ChessPiece.PieceColor.white)
	board.get_square(Vector2(6,0)).piece = Knight.new(ChessPiece.PieceColor.white)

	# Bishops
	board.get_square(Vector2(2,7)).piece = Bishop.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(5,7)).piece = Bishop.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(2,0)).piece = Bishop.new(ChessPiece.PieceColor.white)
	board.get_square(Vector2(5,0)).piece = Bishop.new(ChessPiece.PieceColor.white)

	# Queens
	board.get_square(Vector2(3,7)).piece = Queen.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(3,0)).piece = Queen.new(ChessPiece.PieceColor.white)

	# Kings
	board.get_square(Vector2(4,7)).piece = King.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(4,0)).piece = King.new(ChessPiece.PieceColor.white)
	
	board.colors = [ChessPiece.PieceColor.white, ChessPiece.PieceColor.black]

static func get_traditional_board_setup():
	var board:ChessBoard = ChessBoard.new(Vector2(8,8), [GameConstraint.FriendlyFireConstraint.new(), GameConstraint.NoCheckConstraint.new()])
	board.add_effect(GameEffect.EndOnCheckmate.new())
	board.add_effect(GameEffect.EndOnStalemate.new())
	board.add_effect(GameEffect.PiecesPromoteToQueens.new())

	TraditionalPieces.lay_out_traditional_board(board)

	return board
