class_name Events

signal piece_moved(moving_piece:ChessPiece,original_square :ChessBoard.Square, new_square:ChessBoard.Square)

signal piece_taken(take : ChessPiece.Take)

signal color_lost(color:ChessPiece.PieceColor)

signal game_over(winner:ChessPiece.PieceColor)

signal turn_started(color:ChessPiece.PieceColor)