class_name ChessPiece



class PieceColor:
    var name : String
    var color : Color
    var move_direction : Vector2


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

func move(current_square:ChessBoard.Square, target_square:ChessBoard.Square):
    assert( target_square in get_valid_moves(current_square), "Invalid move %s -> %s" % [current_square.to_string(), target_square.to_string()])
    current_square.piece = null
    target_square.piece = self
    return true

func get_valid_moves(current_square:ChessBoard.Square) -> Array[ChessBoard.Square]:
    return [current_square]

func take(current_square:ChessBoard.Square, target_square:ChessBoard.Square):
    assert( target_square in get_valid_takes(current_square), "Invalid move %s -> %s" % [current_square.to_string(), target_square.to_string()])
    current_square.piece = null
    target_square.piece = self
    return true

func get_valid_takes(current_square:ChessBoard.Square) -> Array[ChessBoard.Square]:
    return [current_square]

func _to_string():
    return color.name + " " + name