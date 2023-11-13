class_name SteamInterface
extends Node

var _INIT: Dictionary
var STEAM_ENABLED: bool = false
var current_lobby : Lobby = null

func _ready():
	OS.set_environment("SteamAppId", "480")
	_INIT = Steam.steamInitEx(true)
	print("Steam Init: " + str(_INIT))
	STEAM_ENABLED = _INIT['status'] == 0

	
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_lobby_join_requested)

	list_lobbies()

func list_lobbies():
	Steam.addRequestLobbyListStringFilter("name", "ChessPlus", Steam.LOBBY_COMPARISON_EQUAL)

	Steam.requestLobbyList()

func _process(_delta: float) -> void:
	if _INIT['status'] == 0:
		Steam.run_callbacks()
	if current_lobby != null:
		current_lobby._process(_delta)

func create_lobby():
	if STEAM_ENABLED:
		current_lobby = Lobby.new(0)

func _on_lobby_match_list(lobbies:Array):
	print("Lobby Match List: " + str(lobbies))

	if len(lobbies) > 0:
		Steam.joinLobby(lobbies[0])
	else:
		create_lobby()

func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int):
	print("Lobby Joined: " + str(lobby_id) + " " + str(_permissions) + " " + str(_locked) + " " + str(response))
	if current_lobby == null or current_lobby._lobby_id != lobby_id:
		var old_lobby = current_lobby
		current_lobby = Lobby.new(lobby_id)
		if old_lobby.board != null:
			current_lobby.attach_lobby_to_board(old_lobby.board)

	current_lobby._get_lobby_members()
	for m in current_lobby.members:
		print(str(m.id) + " " + m.name)
	
func _on_lobby_join_requested(lobby_id: int, friendID: int) -> void:
	print("Lobby Join Requested: " + str(lobby_id) + " " + str(friendID))
	Steam.joinLobby(lobby_id)


class Lobby:
	var created : bool = false
	var _lobby_id:int
	var members :Array = []
	var board : ChessBoard = null
	var hosting : bool = false

	func _init(id:int):
		if id == 0:
			hosting = true
			Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)
		else:
			_lobby_id = id
		Steam.lobby_created.connect(_on_lobby_created)
		Steam.lobby_chat_update.connect(_on_lobby_chat_update)
		Steam.lobby_message.connect(_on_lobby_message)
		Steam.lobby_data_update.connect(_on_lobby_data_update)
		Steam.lobby_invite.connect(_on_lobby_invite)
		Steam.persona_state_change.connect(_on_persona_change)
		Steam.p2p_session_request.connect(_on_p2p_session_request)
		Steam.p2p_session_connect_fail.connect(_on_p2p_session_connect_fail)

		print("Sending P2P handshake to the lobby")

		_send_p2p_packet({"message":"handshake", "from":Steam.getSteamID()}, 0)

	
	func attach_lobby_to_board(_board: ChessBoard):
		board = _board
	
	func send_move(from: ChessBoard.Square, to: ChessBoard.Square):
		_send_p2p_packet({"message":"move", "move": Utils.recursive_to_dict(ChessPiece.Move.new(null, from, to, []))}, 0)

	func send_take(from: ChessBoard.Square, to: ChessBoard.Square):
		_send_p2p_packet({"message":"take", "take": Utils.recursive_to_dict(ChessPiece.Take.new(null, from, to, [], []))}, 0)

	func _get_lobby_members():
		members.clear()

		for m in range(Steam.getNumLobbyMembers(_lobby_id)):
			var id = Steam.getLobbyMemberByIndex(_lobby_id, m)
			if id != Steam.getSteamID():
				members.append(SteamLobbyMember.new(id, Steam.getFriendPersonaName(id)))

	func _on_lobby_created(connected: int, lobby_id: int) -> void:
		print("Lobby Created: " + str(connected) + " " + str(lobby_id))
		if connected:
			_lobby_id = lobby_id

			Steam.setLobbyData(lobby_id, "name", "ChessPlus")
			Steam.setLobbyData(lobby_id, "mode", "Chess+ Testing")

			var RELAY: bool = Steam.allowP2PPacketRelay(true)
			print("Allowing Steam to be relay backup: "+str(RELAY))
			created = true

	func _on_lobby_chat_update(lobby_id: int, steam_id_user_changed: int, steam_id_making_change: int, chat_state_change: int) -> void:
		print("Lobby Chat Update: " + str(lobby_id) + " " + str(steam_id_user_changed) + " " + str(steam_id_making_change) + " " + str(chat_state_change))
		_get_lobby_members()

	func _on_lobby_message(lobby_id: int, steam_id_user: int, message: String) -> void:
		print("Lobby Message: " + str(lobby_id) + " " + str(steam_id_user) + " " + message)

	func _on_lobby_data_update(lobby_id: int, memberID: int, key: int) -> void:
		print("Lobby Data Update: " + str(lobby_id) + " " + str(memberID) + " " + str(key))

	func _on_lobby_invite(invite_id: int, lobby_id: int, steam_id_invited: int) -> void:
		print("Lobby Invite: " + str(invite_id) + " " + str(lobby_id) + " " + str(steam_id_invited))

	func _on_persona_change(steam_id: int, change_flags: int) -> void:
		print("Persona Change: " + str(steam_id) + " " + str(change_flags))

	func _on_p2p_session_request(steam_id: int) -> void:
		print("P2P Session Request: " + str(steam_id))

		Steam.acceptP2PSessionWithUser(steam_id)

	func _on_p2p_session_connect_fail(steam_id: int, session_error: int) -> void:
		print("P2P Session Connect Fail: " + str(steam_id) + " " + str(session_error))

	func _send_p2p_packet(data: Dictionary, target: int) -> void:
		var buffer: PackedByteArray = PackedByteArray()
		buffer.append_array(var_to_bytes(data))
		
		if target == 0:
			for member in members:
				Steam.sendP2PPacket(member.id, buffer, Steam.P2P_SEND_RELIABLE, 0)
		else:
			Steam.sendP2PPacket(target, buffer, Steam.P2P_SEND_RELIABLE, 0)

	func _read_p2p_packet() -> SteamPacket:
		var buffer: PackedByteArray = PackedByteArray()

		var size: int = Steam.getAvailableP2PPacketSize()
		if size > 0:
			buffer.resize(size)
			var packet: Dictionary = Steam.readP2PPacket(size, 0)
			var data = bytes_to_var(packet['data'])

			print("recieved_p2p" + str(data))

			return SteamPacket.new(packet['steam_id_remote'], data)
		else:
			return SteamPacket.new(0,{})

	func _process(_delta:float):
		var p = _read_p2p_packet()
		if p.sender_id != 0:
			if 'message' in p.data:
				if p.data['message'] == "move":
					var move = Utils.recursive_from_dict(p.data['move'])
					board.move(move.from_square.coordinates, move.to_square.coordinates)
				elif p.data['message'] == "take":
					var take = Utils.recursive_from_dict(p.data['take'])
					board.take(take.from_square.coordinates, take.to_square.coordinates)

class SteamLobbyMember:
	var id : int
	var name : String

	func _init(_id: int, _name):
		self.id = _id
		self.name = _name

class SteamPacket:
	var sender_id : int
	var data : Dictionary

	func _init(_sender_id: int, _data: Dictionary):
		self.sender_id = _sender_id
		self.data = _data
