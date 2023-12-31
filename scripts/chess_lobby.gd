class_name ChessLobby

var board_view : ChessBoardView
var player_list : Array = []
var board : ChessBoard
var received_turns : Array = []

signal player_joined(player:ChessPlayer)
signal player_left(player:ChessPlayer)
signal game_started(board:ChessBoard)

static func start_lobby(view : ChessBoardView):
	await(SteamSession.create_lobby())
	return ChessLobby.new(view)

func _init(view : ChessBoardView):
	board_view = view

	for p in SteamSession.current_lobby.members:
		player_list.append(ChessPlayer.new(p.id, p.name, ChessPiece.PieceColor.black))
	player_list.append(ChessPlayer.new(Steam.getSteamID(), Steam.getFriendPersonaName(Steam.getSteamID()), ChessPiece.PieceColor.white))
	
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

func _on_player_left(member:SteamInterface.SteamLobbyMember):
	# Find the player object for the member that left
	for player in player_list:
		if player.id == member.id:
			player_list.erase(player_list.find(player))
			break

func start_game(_board : ChessBoard):
	board = _board
	board_view.set_board(board)
	# Accepts a board, which is sent to all players
	BoardEvent.new(board).send(0)

	# Let everyone know what color they are
	for p in player_list:
		ColorEvent.new(p.color).send(p.id)

	# Binds board events to communicate moves to other players
	bind_board_events()

func bind_board_events():
	board.events.piece_moved.connect_sig(_on_turn_taken)
	board.events.piece_taken.connect_sig(_on_turn_taken)

func _on_turn_taken(option: ChessPiece.TurnOption):
	if not option in received_turns:
		TurnEvent.new(option).send(0)


class ChessPlayer:
	extends SteamInterface.SteamLobbyMember

	var color : ChessPiece.PieceColor

	func _init(_id:int, _name:String, _color:ChessPiece.PieceColor):
		super(_id, _name)
		color = _color

class ChessLobbyEvent:
	func send(target:int):
		SteamSession.current_lobby._send_p2p_packet(Utils.recursive_to_dict(self), target)

	func receive(_lobby:ChessLobby):
		pass

class BoardEvent:
	extends ChessLobbyEvent

	var board : ChessBoard

	func _init(_board:ChessBoard):
		board = _board

	func receive(lobby:ChessLobby):
		lobby.board_view.set_board(board)
		lobby.board=lobby.board_view.board
		lobby.bind_board_events()

class TurnEvent:
	extends ChessLobbyEvent

	var turn_option : ChessPiece.TurnOption

	func _init(_turn_option:ChessPiece.TurnOption):
		turn_option = _turn_option

	func receive(lobby:ChessLobby):
		var turn = turn_option.convert_for_board(lobby.board_view.board)
		lobby.received_turns.append(turn)
		turn.apply_to_board(lobby.board_view.board)

class ColorEvent:
	extends ChessLobbyEvent

	var color : ChessPiece.PieceColor

	func _init(_color:ChessPiece.PieceColor):
		color = _color

	func receive(lobby:ChessLobby):
		lobby.board_view.input.color = color
