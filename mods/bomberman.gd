class_name BomberMan

extends GameEffect
var name:String = "BomberManEffect"

func set_board(_board:ChessBoard):
	super.set_board(_board)
	_board.events.piece_taken.connect_sig(func(take): explode(take))

func explode(take:ChessPiece.Take):
	if take is BombTake:
		return
	var targets:Array[ChessBoard.Square] = []
	for direction in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		var square:ChessBoard.Square = board.get_square(take.to_square.coordinates + direction)
		while square != null:
			if square.piece != null:
				targets.append(square)
			square = board.get_square(square.coordinates + direction)


	var new_take:BombTake = BombTake.new(take.piece, take.to_square, take.to_square, [], targets)
	for target in targets:
		target.piece = null
	await(board.events.piece_taken.emit([new_take]))


func copy():
	var new:BomberMan = BomberMan.new()
	return new

class BombTake:
	extends ChessPiece.Take

	func apply_to_board(board:ChessBoard):
		for target in targets:
			target.piece = null
		await(board.events.piece_taken.emit([self]))

	func convert_for_board(board:ChessBoard):
		var new_take = BombTake.new(piece, from_square, to_square, [], [])
		new_take.from_square = board.get_square(from_square.coordinates)
		new_take.to_square = board.get_square(to_square.coordinates)
		new_take.traversed_squares.clear()
		for square in traversed_squares:
			new_take.traversed_squares.append(board.get_square(square.coordinates))
		new_take.targets.clear()
		for square in targets:
			new_take.targets.append(board.get_square(square.coordinates))
		return new_take

static func get_bomberman_board():
	var _board:ChessBoard = ChessBoard.new(Vector2(8,8), [GameConstraint.FriendlyFireConstraint.new(), GameConstraint.NoCheckConstraint.new()])
	TraditionalPieces.lay_out_traditional_board(_board)
	_board.add_effect(BomberMan.new())
	_board.add_effect(GameEffect.EndOnCheckmate.new())
	_board.add_effect(GameEffect.EndOnStalemate.new())
	_board.add_effect(GameEffect.PiecesPromoteToQueens.new())
	_board.add_effect(GameEffect.LoseOnCheckableTaken.new())

	return _board
