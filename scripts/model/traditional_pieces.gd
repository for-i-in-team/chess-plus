class_name TraditionalPieces

class CanEnPassant:
	extends ChessPiece.PieceModifier

	func get_take_for_square(piece:ChessPiece, board: ChessBoard, _current_square:ChessBoard.Square, target_square:ChessBoard.Square, existing_take:Take) -> Take:
		var _take:ChessPiece.Take = super.get_take_for_square(piece, board, _current_square, target_square, existing_take)

		for row in board.board:
			for square in row.row:
				if square.piece != null and square.piece.color != piece.color:
					var ep_piece : ChessPiece = square.piece
					for modifier in ep_piece.modifiers:
						if modifier is IsEnPassantable:
							if target_square in modifier.en_passantable_coords:
								_take.targets.append(square)
								break

		return _take

class IsEnPassantable:
	extends ChessPiece.PieceModifier

	var en_passantable_coords : Array[ChessBoard.Square] = []

	func turn_started(piece:ChessPiece, _board:ChessBoard, turn_color: ChessPiece.PieceColor):
		if turn_color == piece.color:
			en_passantable_coords = []
	
	func move(piece:ChessPiece, board: ChessBoard, _move:ChessPiece.Move):
		_move = super.move(piece, board, _move)
		en_passantable_coords = _move.traversed_squares
		return _move

class DoubleFirstMove:
	extends PieceMovement.MovePattern

	func _init(_directions:Array[Vector2], _distance:int, _jumps_pieces:bool = false):
		super._init(_directions, _distance*2, _jumps_pieces)

	func move(piece:ChessPiece, board: ChessBoard, _move:ChessPiece.Move):
		super.move(piece, board, _move)
		distance = distance/2

	func take(piece:ChessPiece, board: ChessBoard, _take:ChessPiece.Take):
		super.take(piece, board, _take)
		distance = distance/2


class Pawn:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Pawn", _color, 1, [DoubleFirstMove.new([_color.move_direction],1)], [PieceMovement.TakePattern.new([_color.move_direction + _color.get_perpendicular_direction(), _color.move_direction - _color.get_perpendicular_direction()],1)], [CanEnPassant.new(), IsEnPassantable.new()])

	func copy() -> ChessPiece:
		var new_pawn : Pawn = Pawn.new(color)
		return new_pawn
			
class Rook:
	extends ChessPiece
	
	var has_moved : bool = false

	func _init(_color:ChessPiece.PieceColor):
		super._init("Rook", _color, 5, [PieceMovement.MovePattern.new(PieceMovement.Direction.ORTHOGONAL)], [PieceMovement.TakePattern.new(PieceMovement.Direction.ORTHOGONAL)])

	func move(board: ChessBoard, _move:ChessPiece.Move):
		await(super.move(board, _move))
		has_moved = true

	func take(board:ChessBoard, _take:ChessPiece.Take):
		await(super.take(board, _take))
		has_moved = true

	func copy() -> ChessPiece:
		var new_rook : Rook = Rook.new(color)
		new_rook.has_moved = has_moved
		return new_rook

class Bishop:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Bishop", _color, 3, [PieceMovement.MovePattern.new(PieceMovement.Direction.DIAGONAL)], [PieceMovement.TakePattern.new(PieceMovement.Direction.DIAGONAL)])

	func copy() -> ChessPiece:
		return Bishop.new(color)


class Knight:
	extends ChessPiece

	const KNIGHT_DIRECTIONS:Array[Vector2] = [Vector2(1,2), Vector2(-1,2), Vector2(1,-2), Vector2(-1,-2), Vector2(2,1), Vector2(-2,1), Vector2(2,-1), Vector2(-2,-1)]

	func _init(_color:ChessPiece.PieceColor):
		super._init("Knight", _color, 3, [PieceMovement.MovePattern.new(KNIGHT_DIRECTIONS, 1)], [PieceMovement.TakePattern.new(KNIGHT_DIRECTIONS, 1)])

	func copy() -> ChessPiece:
		return Knight.new(color)


class Queen:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Queen", _color, 8, [PieceMovement.MovePattern.new(PieceMovement.Direction.ALL)], [PieceMovement.TakePattern.new(PieceMovement.Direction.ALL)])
		
	func copy() -> ChessPiece:
		return Queen.new(color)

class King:
	extends ChessPiece

	var has_moved : bool = false

	func _init(_color:ChessPiece.PieceColor):
		super._init("King", _color, 0, [PieceMovement.MovePattern.new(PieceMovement.Direction.ALL, 1)], [PieceMovement.TakePattern.new(PieceMovement.Direction.ALL, 1)])
	
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
			var incidental = ChessPiece.Move.new(next_piece_square.piece, next_piece_square, board.get_square(to_square.coordinates - direction), []) # TODO Set up traversed squares
			return ChessPiece.Move.new(self, current_square, to_square, [], [incidental])
		return null

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
