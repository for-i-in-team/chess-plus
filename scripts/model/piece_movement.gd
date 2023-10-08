class_name PieceMovement


class Direction:
	static var ALL : Array[Vector2] =  [Vector2(1,1), Vector2(-1,1), Vector2(1,-1), Vector2(-1,-1),Vector2(0,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,0)]
	static var DIAGONAL : Array[Vector2] = [Vector2(1,1), Vector2(-1,1), Vector2(1,-1), Vector2(-1,-1)]
	static var ORTHOGONAL : Array[Vector2] = [Vector2(0,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,0)]

class Pattern:
	var directions : Array[Vector2]
	var distance:int
	var jumps_pieces:bool

	func _init(_directions:Array[Vector2], _distance:int = -1, _jumps_pieces:bool = false):
		directions = _directions
		distance = _distance
		jumps_pieces = _jumps_pieces

	func move(_piece:ChessPiece,_board:ChessBoard, _move:ChessPiece.Move):
		pass

	func take(_piece:ChessPiece,_board:ChessBoard, _take:ChessPiece.Take):
		pass

	func is_blocked(square:ChessBoard.Square):
		return square == null or (not jumps_pieces and square.piece != null)

class MovePattern:
	extends Pattern

	func get_valid_moves(piece:ChessPiece, board:ChessBoard, current_square:ChessBoard.Square) -> Array[ChessPiece.Move]:
		var moves:Array[ChessPiece.Move] = []
		for direction in directions:
			var traversed:Array[ChessBoard.Square] = []
			if distance > 0:
				for i in range(distance):
					var square:ChessBoard.Square = board.get_square(current_square.coordinates + direction * (i+1))
					if is_blocked(square):
						break
					elif len(piece.get_take_for_square(board, current_square, square, traversed).targets) == 0:
						moves.append(ChessPiece.Move.new(piece, current_square, square, traversed))
					traversed.append(square)
			else:
				var next_square = board.get_square(current_square.coordinates + direction)
				while next_square != null:
					if is_blocked(next_square):
						break
					elif len(piece.get_take_for_square(board, current_square, next_square, traversed).targets) == 0:
						moves.append(ChessPiece.Move.new(piece, current_square, next_square, traversed))
					traversed.append(next_square)
					next_square = board.get_square(next_square.coordinates + direction)

		return moves


	
class TakePattern:
	extends Pattern

	func get_valid_takes(piece:ChessPiece, board:ChessBoard, current_square:ChessBoard.Square) -> Array[ChessPiece.Take]:
		var takes:Array[ChessPiece.Take] = []

		for direction in directions:
			var traversed:Array[ChessBoard.Square] = []
			if distance > 0:
				for i in range(distance):
					var square:ChessBoard.Square = board.get_square(current_square.coordinates + direction * (i+1))
					if square == null:
						break
					else:
						var _take:ChessPiece.Take = piece.get_take_for_square(board, current_square, square, traversed)
						if len(_take.targets)>0:
							takes.append(_take)
							if is_blocked(square):
								break
					traversed.append(square)
			else:
				var next_square = board.get_square(current_square.coordinates + direction)
				while next_square != null:
					var _take:ChessPiece.Take =piece.get_take_for_square(board, current_square, next_square, traversed)
					traversed.append(next_square)
					if len(_take.targets)>0:
						takes.append(_take)
						if is_blocked(next_square):
							break
					next_square = board.get_square(next_square.coordinates + direction)

		return takes

