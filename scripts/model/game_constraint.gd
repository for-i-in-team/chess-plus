class_name GameConstraint

func _init(_requires_next_state:bool):
    self.requires_next_state = _requires_next_state

func validate_move(_board:ChessBoard, _origin:ChessBoard.Square, _destination:ChessBoard.Square, _next_state:ChessBoard):
    assert(false, "GameConstraint.validate_move() must be implemented by subclasses")

func validate_take(_board:ChessBoard, _take:ChessPiece.Take,_next_state:ChessBoard):
    assert(false, "GameConstraint.validate_take() must be implemented by subclasses")