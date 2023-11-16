class_name ChessPieceView

extends Node2D

const move_speed = 1.2

var piece_id : int
var target_dest :Vector2
var initial_position:Vector2
var move_progress :float = 0.0
var moving :bool = false
var taken:bool = false
var board : ChessBoardView

signal move_complete()
signal take_complete()

func init(_board:ChessBoardView, chess_piece:ChessPiece):
	piece_id = chess_piece.id
	z_index = 5
	$sprite.texture = get_image(chess_piece)
	$sprite.modulate = chess_piece.color.color
	board=  _board
	board.board.events.piece_moved.connect_sig(func(_move:ChessPiece.Move):
		if _move.piece.id == piece_id:
			await(move(_move.from_square, _move.to_square))
		for incidental in _move.incidental:
			if incidental.piece.id == piece_id:
				await(move(incidental.from_square, incidental.to_square))
	)
	
	board.board.events.piece_taken.connect_sig(func(take:ChessPiece.Take):
		if take.piece.id == piece_id:
			await(move(take.from_square, take.to_square))
			return
		var square_view : ChessSquareView = get_parent()

		for t in take.targets:
			if not taken and square_view.square.coordinates == t.coordinates:
				taken = true
				await(take_complete)
				break
	)

	board.board.events.piece_change.connect_sig(func(old_piece:ChessPiece, new_piece:ChessPiece):
		if old_piece.id == piece_id:
			piece_id = new_piece.id
			$sprite.texture = get_image(new_piece)
			$sprite.modulate = new_piece.color.color
	)

func move(from_square:ChessBoard.Square, to_square:ChessBoard.Square):
	if from_square != to_square:
		var to_view : ChessSquareView = board.get_square_view(to_square)
		target_dest = to_view.global_position
		initial_position = global_position
		
		moving = true
		move_progress = 0.0

		await(move_complete)

		moving = false
		get_parent().remove_child(self)
		to_view.add_child(self)
		position = Vector2(0,0)

func get_image(load_piece:ChessPiece) -> Texture:
	return load("res://resources/pieces/"+load_piece.name.to_lower() + ".png")


func _process(delta):
	if moving:
		if global_position.distance_to(initial_position) <= target_dest.distance_to(initial_position):
			move_progress += delta*move_speed
			global_position = initial_position.lerp(target_dest, move_progress)
		else:
			move_complete.emit()

	if taken:
		$sprite.modulate.a = $sprite.modulate.a - 0.01
		if $sprite.modulate.a <= 0:
			take_complete.emit()
