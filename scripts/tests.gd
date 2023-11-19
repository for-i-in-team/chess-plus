class_name Tests


func simple_8x8():
	var board:ChessBoard = ChessBoard.new(Vector2(8,8), [GameConstraint.FriendlyFireConstraint.new(), GameConstraint.NoCheckConstraint.new()])
	board.add_effect(GameEffect.EndOnCheckmate.new())
	board.add_effect(GameEffect.EndOnStalemate.new())
	board.add_effect(GameEffect.PiecesPromoteToQueens.new())
	board.add_effect(GameEffect.LoseOnCheckableTaken.new())
	board.colors = [ChessPiece.PieceColor.white, ChessPiece.PieceColor.black]

	board.get_square(Vector2(5, 0)).piece = (TraditionalPieces.Rook.new(ChessPiece.PieceColor.black))

	board.get_square(Vector2(3, 4)).piece = (TraditionalPieces.King.new(ChessPiece.PieceColor.black))

	board.get_square(Vector2(2, 1)).piece = (TraditionalPieces.Bishop.new(ChessPiece.PieceColor.white))

	board.get_square(Vector2(6, 7)).piece = (TraditionalPieces.King.new(ChessPiece.PieceColor.white))

	board.get_square(Vector2(5, 4)).piece = (TraditionalPieces.Knight.new(ChessPiece.PieceColor.white))


	return board

static var pre_init_times : Array[int] = []
static var post_init_times : Array[int] = []

class TestBoardRow:
	var row:Array[TestSquare]
	func _init(row_num:int, row_length:int):
		var start_time = Time.get_ticks_usec()
		for i in range(row_length):
			#var color : SquareColor = SquareColor.black if (i+row_num)%2 == 0 else SquareColor.white
			var v = Vector2(i,row_num)
			var _start_time = Time.get_ticks_usec()
			var s = TestSquare.new(ChessBoard.SquareColor.white, v, Time.get_ticks_usec())
			PerformanceTracker.add_call_time("Square.post_init", Time.get_ticks_usec() - s.end_init_time)	
			row.append(s)
			PerformanceTracker.add_call_time("BoardRow.create_square", Time.get_ticks_usec() - _start_time)	
			row.append(s)
		
		PerformanceTracker.add_call_time("BoardRow._init", Time.get_ticks_usec() - start_time)

class TestSquare:
	var color:ChessBoard.SquareColor
	var coordinates : Vector2
	var piece : ChessPiece
	var end_init_time : int

	func _init( square_color:ChessBoard.SquareColor, coord : Vector2, time:int):	
		PerformanceTracker.add_call_time("Square.pre_init", Time.get_ticks_usec() - time)	
		var _start_time = Time.get_ticks_usec()
		color  = square_color
		coordinates = coord
		
		PerformanceTracker.add_call_time("Square._init", Time.get_ticks_usec() - _start_time)
		end_init_time = Time.get_ticks_usec()

		

func test_object_instantiation_speed():
	var start_time = Time.get_ticks_usec()
	for i in range(10000):
		var t = TestBoardRow.new(i%8, 8)
	var total_time = Time.get_ticks_usec() - start_time

	
	PerformanceTracker.display_performance_summary(total_time)
	breakpoint
	
	var post_total = 0
	for time in post_init_times:
		post_total += time
	var post_average = post_total / post_init_times.size()
	

	var pre_total = 0
	for time in pre_init_times:
		pre_total += time
	var pre_average = pre_total / pre_init_times.size()

	print("Total time: " + str(total_time))
	print("Pre_init average time: " + str(pre_average))
	print("Post_init average time: " + str(post_average))
	print("Instantiation Percentage: " + str(((post_total + pre_total) / total_time) * 100) + "%")
	

func test_ai_speed():
	var board : ChessBoard# = BomberMan.get_bomberman_board()
	var _bot : ChessAI
	var times : Array[int] = []
	var total:int = 0
	performance_test(func():
		var board_list : Array[ChessBoard.BoardRow]= []
		for i in range(8):
			board_list.append(ChessBoard.BoardRow.new(i,8))
		,
		24000
	)

	breakpoint
	for i in range(20):
		board = BomberMan.get_bomberman_board()
		_bot = ChessAI.new(ChessPiece.PieceColor.black, board)
		var moves : Array[ChessPiece.Move] = board.get_square(Vector2(5,1)).piece.get_valid_moves(board, board.get_square(Vector2(5,1)))
		var start_time = Time.get_ticks_usec()
		board.move(moves[0].from_square.coordinates, moves[0].to_square.coordinates)
		times.append(Time.get_ticks_usec() - start_time)
	print(times)
	total = 0
	for time in times:
		total += time
	print("Average: " + str(total/ times.size()))
	
	PerformanceTracker.display_performance_summary(total)
	

func performance_test(function : Callable, iterations : int = 10000):
	var times : Array[int] = []
	var total : int = 0
	for i in range(iterations):
		var start_time = Time.get_ticks_usec()
		function.call()

		times.append(Time.get_ticks_usec() - start_time)
		
	for time in times:
		total += time
	print("Average: " + str(total / times.size()))
	print("Total: " + str(total))
	
	PerformanceTracker.display_performance_summary(total)


class ChildObject:
	var id : int

	func _init(id:int):
		self.id = id

class SerialisableObject:

	var a : int
	var some_array : Array[int]
	var some_dict : Dictionary
	var some_string : String
	var custom_object : ChildObject

	func _init(a:int, some_array:Array, some_dict:Dictionary, some_string:String, custom_object_id:int):
		self.a = a
		self.some_array = some_array
		self.some_dict = some_dict
		self.some_string = some_string
		self.custom_object = ChildObject.new(custom_object_id)

static func serialisation_tests():
	simple_bytes_to_var_test()
	var some_object : SerialisableObject = SerialisableObject.new(5, [1,2,3,4,5], {"a":1, "b":2, "c":3}, "Hello World", 5)

	test_deserialisation(some_object, bytes_to_var(var_to_bytes(some_object)))

	test_deserialisation(some_object, str_to_var(var_to_str(some_object)))
	
	test_deserialisation(some_object, bytes_to_var_with_objects(var_to_bytes_with_objects(some_object)))

	test_deserialisation(some_object, dict_to_inst(inst_to_dict(some_object)))

	
	inst_to_dict_test()

	breakpoint
	
static func test_deserialisation(original, deserialised):
	assert(deserialised != null, "Deserialisation produced a null value")
	assert(original.a == deserialised.a, "Serialisation failed to preserve integer identity")
	assert(original.some_string == deserialised.some_string, "Serialisation failed to preserve string identity")
	assert(len(original.some_array) == len(deserialised.some_array), "Serialisation failed to preserve list contents")
	assert(len(original.some_dict) == len(deserialised.some_dict), "Serialisation failed to preserve dictionary contents")
	assert(original.custom_object.id == deserialised.custom_object.id, "Serialisation failed to preserve attributes of child objects")
	assert(deserialised is SerialisableObject, "Serialisation failed to preserve object type")
	print("Successful deserialisation!")

static func inst_to_dict_test():
	var some_object : SerialisableObject = SerialisableObject.new(5, [1,2,3,4,5], {"a":1, "b":2, "c":3}, "Hello World", 5)
	var dict = inst_to_dict(some_object)

	for key in dict.keys():
		assert(not dict[key] is Object, "inst_to_dict failed to convert " + key +" to variant")

class TestClass:
	var a : int
	
	func _init(a : int):
		self.a = a

static func simple_bytes_to_var_test():

	var some_object : TestClass = TestClass.new(5)
	var bytes = var_to_bytes_with_objects(some_object)
	print(bytes)
	var deserialised = bytes_to_var_with_objects(bytes)
	assert(deserialised != null, "Deserialisation produced a null value")
