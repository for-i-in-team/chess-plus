class_name Events

signal piece_moved(moving_piece:ChessPiece,original_square :ChessBoard.Square, new_square:ChessBoard.Square)

signal piece_taken(original_square :ChessBoard.Square, new_square :ChessBoard.Square, taking_piece:ChessPiece, taken_piece:ChessPiece)