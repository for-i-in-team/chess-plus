class_name SquareHighlighter

extends Sprite2D



func init(chess_square:ChessSquareView, highlight_color:Color):
	modulate = highlight_color
	modulate.a = 0.5
	z_index = 10
	position = chess_square.position
	scale = chess_square.get_sprite_scale()
	position = chess_square.position
