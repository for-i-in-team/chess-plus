class_name ChessLobby

var player_list : Array = []
var board : ChessBoard
var received_turns : Array = []
var isHost : bool = false

signal player_joined(player:ChessPlayer)
signal player_left(player:ChessPlayer)
signal game_started(board:ChessBoard)
signal board_changed(board:ChessBoard)
signal player_data_updated()

static func start_lobby():
	await(SteamSession.create_lobby())
	return ChessLobby.new(true)

func update_player_color(id:String, color:ChessPiece.PieceColor):
	for player in player_list:
		if player.id == id:
			player.color = color
			player_data_updated.emit()
			break

func _init(hosting:bool = false):
	SteamSession.chess_lobby = self
	isHost = hosting
	for p in SteamSession.current_lobby.members:
		player_list.append(ChessPlayer.new(p.id, p.name, ChessPiece.PieceColor.black))
	player_list.append(ChessPlayer.new(SteamSession.getSteamID(), SteamSession.getUsername(), ChessPiece.PieceColor.white))
	
	# Bind events to track players in the lobby
	SteamSession.current_lobby.member_joined.connect(_on_player_joined)
	SteamSession.current_lobby.member_left.connect(_on_player_left)
	SteamSession.current_lobby.message_received.connect(handle_message)

func handle_message(packet : SteamInterface.SteamPacket):
	var event = Utils.recursive_from_dict(packet.data)
	event.receive(self)

func _on_player_joined(member:SteamInterface.SteamLobbyMember):
	# Create a new player object for the new member
	var color : ChessPiece.PieceColor
	if player_list.any(func(p:ChessPlayer): return p.id == member.id):
		return
	if len(player_list) > 0 and player_list[-1].color == ChessPiece.PieceColor.white:
		color = ChessPiece.PieceColor.black
	else:
		color = ChessPiece.PieceColor.white
	var player = ChessPlayer.new(member.id, member.name, color)
	player_list.append(player)
	player_joined.emit(player)
	if isHost:
		print("Sending " + str(player.id) + " lobby data event")
		LobbyDataEvent.new(board, player_list).send_to(player.id)

func _on_player_left(member:SteamInterface.SteamLobbyMember):
	# Find the player object for the member that left
	for player in player_list:
		if player.id == member.id:
			player_list.erase(player_list.find(player))
			break

func start_game(_board : ChessBoard):
	board = _board
	
	load_game_scene()
	# Accepts a board, which is sent to all players
	StartGameEvent.new(board).send()
	
	bind_board_events()

	# Let everyone know what color they are
	for p in player_list:
		PlayerColorUpdatedEvent.new(p.color, p.id).send()

func load_game_scene():
	var player_color
	var ai_colors : Array = []
	for p in player_list:
		if p.id == SteamSession.getSteamID():
			player_color = p.color
		if p is ChessBot and isHost:
			ai_colors.append(p.color)
	
	ChessBoardView.Scene.new(board, ai_colors, player_color).load_scene()

func set_board(_board : ChessBoard):
	board = _board
	bind_board_events()
	board_changed.emit(board)

func set_players(_player_list : Array):
	player_list = _player_list
	player_data_updated.emit()

func bind_board_events():
	board.events.piece_moved.connect_sig(_on_turn_taken)
	board.events.piece_taken.connect_sig(_on_turn_taken)

func _on_turn_taken(option: ChessPiece.TurnOption):
	if not option in received_turns:
		TurnEvent.new(option).send()

func kick(player:int):
	print("Kicking player " + str(player))

func add_bot():
	var color : ChessPiece.PieceColor = ChessPiece.PieceColor.black if len(player_list) > 0 and player_list[-1].color == ChessPiece.PieceColor.white else  ChessPiece.PieceColor.white
	player_list.append(ChessBot.new(color))
	player_joined.emit(player_list[-1])


class ChessPlayer:
	extends SteamInterface.SteamLobbyMember

	var color : ChessPiece.PieceColor

	func _init(_id:String, _name:String, _color:ChessPiece.PieceColor):
		super(_id, _name)
		color = _color

class ChessBot:
	extends ChessPlayer

	func _init(_color:ChessPiece.PieceColor):
		super("bot", "Bot", _color)



class ChessLobbyEvent:
	func send():
		SteamSession.current_lobby._send_p2p_packet(Utils.recursive_to_dict(self), SteamSession.TARGET_ALL)

	func send_to(target:String):
		SteamSession.current_lobby._send_p2p_packet(Utils.recursive_to_dict(self), target)

	func receive(_lobby:ChessLobby):
		pass

class StartGameEvent:
	extends ChessLobbyEvent

	var board : ChessBoard

	func _init(_board:ChessBoard):
		board = _board

	func receive(lobby:ChessLobby):
		lobby.set_board(board)
		lobby.load_game_scene()

class TurnEvent:
	extends ChessLobbyEvent

	var turn_option : ChessPiece.TurnOption

	func _init(_turn_option:ChessPiece.TurnOption):
		turn_option = _turn_option

	func receive(lobby:ChessLobby):
		var turn = turn_option.convert_for_board(lobby.board)
		lobby.received_turns.append(turn)
		turn.apply_to_board(lobby.board)

class PlayerColorUpdatedEvent:
	extends ChessLobbyEvent

	var color : ChessPiece.PieceColor
	var player_id : String

	func _init(_color:ChessPiece.PieceColor, _player_id:String):
		color = _color
		player_id = _player_id

	func receive(lobby:ChessLobby):
		for player in lobby.player_list:
			if player.id == player_id:
				player.color = color
				lobby.player_data_updated.emit()

class LobbyDataEvent:
	extends ChessLobbyEvent

	var board : ChessBoard
	var player_list : Array = []

	func _init(_board:ChessBoard, _player_list:Array):
		board = _board
		player_list = _player_list

	func receive(lobby:ChessLobby):
		lobby.set_board(board)
		lobby.set_players(player_list)
