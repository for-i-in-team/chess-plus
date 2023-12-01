class_name LevelSelectMenu

extends Node2D

@export var puzzle_display : PackedScene
@export var first_puzzle_pos : Vector2
var puzzles : Array[ChessBoard.Puzzle] = []

func start_game(puzzle:ChessBoard.Puzzle):
	ChessBoardView.Scene.new(puzzle.get_board(), [ChessPiece.PieceColor.black]).load_scene()

func spawn_puzzle_display(pos:Vector2, puzzle:ChessBoard.Puzzle):
	var display = puzzle_display.instantiate()
	display.position = pos
	add_child(display)
	display.set_puzzle(puzzle)
	display.get_on_press().connect(func(): start_game(puzzle))

func get_puzzles():
	var mods = DirAccess.open("res://mods")

	mods.list_dir_begin()
	while true:
		var file = mods.get_next()
		if file == "":
			break
		if file.ends_with("_mod.gd"):
			var path = "res://mods/" + file
			var mod = load(path)
			if mod.Puzzle != null:
				var puzzle = mod.Puzzle.new()
				puzzles.append(puzzle)
		elif mods.dir_exists("res://mods/" + file):
			var mod_dir = DirAccess.open("res://mods/" + file)
			mod_dir.list_dir_begin()
			while true:
				var subfile = mod_dir.get_next()
				if subfile == "":
					break
				if subfile.ends_with("_mod.gd"):
					var path = "res://mods/" + file + "/" + subfile
					var mod = load(path)
					if 'Puzzle' in mod:
						var puzzle = mod.Puzzle.new()
						puzzles.append(puzzle)

func _ready():
	get_puzzles()

	var pos = first_puzzle_pos
	for puzzle in puzzles:
		spawn_puzzle_display(pos, puzzle)
		pos.x += 200


class Scene:
	extends SceneManager.Scene

	func get_packed_scene() -> PackedScene:
		return preload("res://scenes/screens/level_select.tscn")
