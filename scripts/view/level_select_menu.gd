class_name LevelSelectMenu

extends Node2D

@export var puzzle_display : PackedScene
@export var first_puzzle_pos : Vector2
var puzzles : Array[Puzzle] = []

func start_game(puzzle:Puzzle):
	ChessBoardView.Scene.new(puzzle.get_board(), [ChessPiece.PieceColor.black]).load_scene()

func spawn_puzzle_display(pos:Vector2, puzzle:Puzzle):
	var display = puzzle_display.instantiate()
	display.position = pos
	add_child(display)
	display.set_puzzle(puzzle)
	display.get_on_press().connect(func(): start_game(puzzle))

func _ready():
	puzzles.append(TraditionalPuzzle.new())
	puzzles.append(BombermanPuzzle.new())

	var pos = first_puzzle_pos
	for puzzle in puzzles:
		spawn_puzzle_display(pos, puzzle)
		pos.x += 200

class Puzzle:
	
	func get_name() -> String:
		return ""

	func get_board() -> ChessBoard:
		return null

class TraditionalPuzzle:
	extends Puzzle

	func get_name() -> String:
		return "Traditional"

	func get_board() -> ChessBoard:
		return TraditionalPieces.get_traditional_board_setup()

class BombermanPuzzle:
	extends Puzzle

	func get_name() -> String:
		return "Bomberman"

	func get_board() -> ChessBoard:
		return BomberMan.get_bomberman_board()

class Scene:
	extends SceneManager.Scene

	func get_packed_scene() -> PackedScene:
		return preload("res://scenes/screens/level_select.tscn")
