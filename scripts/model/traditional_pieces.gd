class_name TraditionalPieces

class CanEnPassant:
	extends ChessPiece.PieceModifier

	func get_take_for_square(piece:ChessPiece, board: ChessBoard, _current_square:ChessBoard.Square, target_square:ChessBoard.Square, existing_take:Take) -> Take:
		var _take:ChessPiece.Take = super.get_take_for_square(piece, board, _current_square, target_square, existing_take)

		for row in board.board:
			for square in row.row:
				if square.piece != null and square.piece.color != piece.color:
					var modifier = square.piece.get_modifier(IsEnPassantable)
					if modifier != null and target_square.coordinates in modifier.en_passantable_coords:
							_take.targets.append(square)
							break

		return _take

class IsEnPassantable:
	extends ChessPiece.PieceModifier

	var en_passantable_coords : Array[Vector2] = []

	func turn_started(piece:ChessPiece, _board:ChessBoard, turn_color: ChessPiece.PieceColor):
		if turn_color == piece.color:
			en_passantable_coords = []
	
	func move(piece:ChessPiece, board: ChessBoard, _move:ChessPiece.Move):
		_move = super.move(piece, board, _move)
		en_passantable_coords = []
		for sq in _move.traversed_squares:
			en_passantable_coords.append(sq.coordinates)
		return _move

	func copy():
		var _copy = IsEnPassantable.new()
		_copy.en_passantable_coords = en_passantable_coords.duplicate()
		return _copy

class DoubleFirstMove:
	extends PieceMovement.MovePattern

	var has_moved:bool = false

	func _init(_directions:Array[Vector2], _distance:int, _jumps_pieces:bool = false):
		super._init(_directions, _distance*2, _jumps_pieces)

	func move(piece:ChessPiece, board: ChessBoard, _move:ChessPiece.Move):
		super.move(piece, board, _move)
		if !has_moved:
			has_moved = true
			distance = distance/2

	func take(piece:ChessPiece, board: ChessBoard, _take:ChessPiece.Take):
		super.take(piece, board, _take)
		if !has_moved:
			has_moved = true
			distance = distance/2

	func copy():
		var _copy = DoubleFirstMove.new(directions, distance, jumps_pieces)
		_copy.has_moved = has_moved
		return _copy

class CastlePattern:
	extends PieceMovement.MovePattern

	var has_moved:bool = false

	func _init(_directions= PieceMovement.Direction.ALL, _distance=2):
		super._init(_directions, _distance)

	func move(piece:ChessPiece, board: ChessBoard, _move:ChessPiece.Move):
		super.move(piece, board, _move)
		has_moved = true

	func take(piece:ChessPiece, board: ChessBoard, _take:ChessPiece.Take):
		super.take(piece, board, _take)
		has_moved = true

	func get_valid_moves(piece:ChessPiece, board:ChessBoard, current_square:ChessBoard.Square) -> Array[ChessPiece.Move]:
		var check_mod = piece.get_modifier(Checkable)
		if has_moved or (check_mod != null and check_mod.is_in_check(piece, board, current_square)):
			return []
		var valid_moves : Array[ChessPiece.Move] = []
		# For each direction
		for direction in directions:
			# Get next piece in that direction
			var next_piece_square = test_in_direction(board, current_square, direction, func(square:ChessBoard.Square): return square.piece != null)

			# If the piece is further away then the potential move, check if it can castle
			var end_square_coords = current_square.coordinates + direction * distance
			if next_piece_square != null and next_piece_square.piece.color == piece.color and current_square.coordinates.distance_to(end_square_coords) < current_square.coordinates.distance_to(next_piece_square.coordinates) and can_castle(board, next_piece_square, board.get_square(end_square_coords - direction)):
				# If it can, add the move
				valid_moves.append(get_castle_move(piece, board, current_square, board.get_square(end_square_coords), direction, next_piece_square))
		return valid_moves
				

	func can_castle(board, square:ChessBoard.Square, end_square:ChessBoard.Square) -> bool:
		var mod = square.piece.get_modifier(CanCastle)
		if mod != null and !mod.has_moved:
			var moves : Array[ChessPiece.Move] = square.piece.get_valid_moves(board, square)
			for _move in moves:
				if _move.to_square == end_square:
					return true

		return false

	func get_castle_move(piece:ChessPiece, board:ChessBoard, current_square:ChessBoard.Square, to_square:ChessBoard.Square, direction:Vector2, next_piece_square:ChessBoard.Square) -> ChessPiece.Move:
		var threat_squares : Array[ChessBoard.Square] = []
		
		var sq : ChessBoard.Square = board.get_square(current_square.coordinates + direction)
		while sq != to_square:
			threat_squares.append(sq)
			sq = board.get_square(sq.coordinates + direction)

		var incidental = ChessPiece.Move.new(next_piece_square.piece, next_piece_square, board.get_square(to_square.coordinates - direction), [])
		return ChessPiece.Move.new(piece, current_square, to_square, threat_squares, [incidental])

	func copy():
		var _copy = CastlePattern.new()
		_copy.has_moved = has_moved
		return _copy
	
class CanCastle:
	extends ChessPiece.PieceModifier

	var has_moved:bool = false

	func move(piece:ChessPiece, board: ChessBoard, _move:ChessPiece.Move):
		has_moved = true
		return await(super.move(piece, board, _move))

	func take(piece:ChessPiece, board: ChessBoard, _take:ChessPiece.Take):
		has_moved = true
		return await(super.take(piece, board, _take))

	func copy():
		var _copy = CanCastle.new()
		_copy.has_moved = has_moved
		return _copy

class Checkable:
	extends ChessPiece.PieceModifier

	func is_in_check(piece: ChessPiece, board:ChessBoard, current_square:ChessBoard.Square) -> bool:
		for row in board.board:
			for square in row.row:
				if square.piece != null and square.piece.color != piece.color:
					var valid_takes = square.piece.get_valid_takes(board, square)
					for _take in valid_takes:
						if _take.targets.find(current_square) != -1:
							return true
		return false



class Pawn:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Pawn", _color, 1, [DoubleFirstMove.new([_color.move_direction],1)], [PieceMovement.TakePattern.new([_color.move_direction + _color.get_perpendicular_direction(), _color.move_direction - _color.get_perpendicular_direction()],1)], [CanEnPassant.new(), IsEnPassantable.new()])
			
class Rook:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Rook", _color, 5, [PieceMovement.MovePattern.new(PieceMovement.Direction.ORTHOGONAL)], [PieceMovement.TakePattern.new(PieceMovement.Direction.ORTHOGONAL)], [CanCastle.new()])

class Bishop:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Bishop", _color, 3, [PieceMovement.MovePattern.new(PieceMovement.Direction.DIAGONAL)], [PieceMovement.TakePattern.new(PieceMovement.Direction.DIAGONAL)])

class Knight:
	extends ChessPiece

	const KNIGHT_DIRECTIONS:Array[Vector2] = [Vector2(1,2), Vector2(-1,2), Vector2(1,-2), Vector2(-1,-2), Vector2(2,1), Vector2(-2,1), Vector2(2,-1), Vector2(-2,-1)]

	func _init(_color:ChessPiece.PieceColor):
		super._init("Knight", _color, 3, [PieceMovement.MovePattern.new(KNIGHT_DIRECTIONS, 1)], [PieceMovement.TakePattern.new(KNIGHT_DIRECTIONS, 1)])


class Queen:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Queen", _color, 8, [PieceMovement.MovePattern.new(PieceMovement.Direction.ALL)], [PieceMovement.TakePattern.new(PieceMovement.Direction.ALL)])

class King:
	extends ChessPiece


	func _init(_color:ChessPiece.PieceColor):
		super._init("King", _color, 0, [PieceMovement.MovePattern.new(PieceMovement.Direction.ALL, 1), CastlePattern.new()], [PieceMovement.TakePattern.new(PieceMovement.Direction.ALL, 1)], [Checkable.new()])


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
