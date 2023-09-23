class_name ChessPiece



class PieceColor:
    var name : String
    var color : Color
    var move_direction : Vector2
    func get_perpendicular_direction():
        return Vector2(move_direction.y, move_direction.x)


class White:
    extends PieceColor
    func _init():
        name = "White"
        color = Color(1, 1, 1)
        move_direction = Vector2(0, 1)


class Black:
    extends PieceColor
    func _init():
        name = "Black"
        color = Color(0, 0, 0)
        move_direction = Vector2(0, -1)

var name : String
var color : PieceColor
var point_value : float

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

func _to_string():
    return color.name + " " + name