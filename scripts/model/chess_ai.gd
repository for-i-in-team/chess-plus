class_name ChessAI

var color : ChessPiece.PieceColor
var board : ChessBoard
var search_depth:int = 0

func _init(_color : ChessPiece.PieceColor, _board : ChessBoard):
	color = _color
	board = _board

	board.events.turn_started.connect_sig(func (_color : ChessPiece.PieceColor):
		if _color == color:
			play_turn()
	)

func play_turn():
	var option = await(get_best_option(board, color, 0))
	option.option.apply_to_board(board)

func get_best_option(_board:ChessBoard, _color:ChessPiece.PieceColor, depth:int):
	var options : Array[ChessPiece.TurnOption] = await(_board.get_all_options(_color))
	assert(len(options) > 0, "No moves available for this color on this board " + color.name)
	var indent : String = ""
	for i in range(depth):
		indent += "  "
	var best_option : ChessPiece.TurnOption = null
	var best_value : int = -99999
	for option in options:
		print("%sTrying move %s from %s to %s for %s" % [indent, option.piece.name, str(option.from_square.coordinates), str(option.to_square.coordinates), _color.name])
		var new_board = await(option.copy_on_board(_board))
		var value = await(get_board_value_recursive(new_board, _color, depth))
		print("%sValue of move %s from %s to %s is %s for %s" % [indent, option.piece.name, str(option.from_square.coordinates), str(option.to_square.coordinates), str(value), _color.name])
		if value >= best_value:
			best_option = option
			best_value = value
	
	return OptionValue.new(best_option, best_value)

func get_board_value_recursive(_board : ChessBoard, _color : ChessPiece.PieceColor, depth:int) -> int:
	if depth >= search_depth:
		return get_board_value(_board, _color)
	var indent : String = ""
	for i in range(depth):
		indent += "  "

	# Simulate opponents moves
	while _board.current_turn != _color: # TODO Tweak return value to be reduced by how far away it is? At least for win/loss states
		if not _color in _board.colors:
			print("%sReturning board value of -99999 for %s" % [indent, _board.current_turn.name])
			return -99999
		var best_option : OptionValue = await(get_best_option(_board, _board.current_turn, depth+1))

		best_option.option.apply_to_board(_board)

	var best_option : OptionValue = await(get_best_option(_board, _color, depth+1))
	print("%sReturning board value of %s for %s" % [indent, str(best_option.value), _color.name])
	return best_option.value

func get_board_value(_board : ChessBoard, _color : ChessPiece.PieceColor):
	var value = 0
	if len(_board.colors) <= 1 and _board.colors[0] == _color:
		return 99999
	elif len(_board.colors) <= 1:
		return -99999
	var start_time = Time.get_ticks_usec()
	for row in _board.board:
		for square in row.row:
			if square.piece != null:
				if square.piece.color == _color:
					value += square.piece.point_value
				else:
					value -= square.piece.point_value
	print("Time taken: %s" % [Time.get_ticks_usec() - start_time])
	return value

class OptionValue:
	var option : ChessPiece.TurnOption
	var value : int

	func _init(_option : ChessPiece.TurnOption, _value : int):
		option = _option
		value = _value
