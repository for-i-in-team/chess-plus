

class_name ChessBoard






class SquareColor:
    var color: Color

class Black: 
    extends SquareColor 
    func _init():
        self.color = Color.BLACK

class White:
    extends SquareColor
    func _init():
        self.color = Color.WHITE
    