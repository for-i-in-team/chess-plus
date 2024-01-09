class_name SteamInterface
extends Node

var _INIT: Dictionary
var STEAM_ENABLED: bool = false
var current_lobby : Lobby = null

signal lobby_joined()

func _ready():
	OS.set_environment("SteamAppId", "480")
	_INIT = Steam.steamInitEx(true)
	print("Steam Init: " + str(_INIT))
	STEAM_ENABLED = _INIT['status'] == 0

	
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_lobby_join_requested)
	lobby_joined.connect(func(): VersusLobby.Scene.new(ChessLobby.new()).load_scene())

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
	assert(STEAM_ENABLED, "Steam has not initialised, output was " + str(_INIT))
	current_lobby = Lobby.new(0)
	await(Steam.lobby_created)

func _on_lobby_match_list(lobbies:Array):
	print("Lobby Match List: " + str(lobbies))

func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int):
	print("Lobby Joined: " + str(lobby_id) + " " + str(_permissions) + " " + str(_locked) + " " + str(response))
	if current_lobby == null or current_lobby._lobby_id != lobby_id:
		current_lobby = Lobby.new(lobby_id)

		current_lobby.update_lobby_members()
		for m in current_lobby.members:
			print(str(m.id) + " " + m.name)

		lobby_joined.emit()
	
func _on_lobby_join_requested(lobby_id: int, friendID: int) -> void:
	print("Lobby Join Requested: " + str(lobby_id) + " " + str(friendID))
	Steam.joinLobby(lobby_id)

func wait(seconds : float):
	await(get_tree().create_timer(seconds).timeout)


class Lobby:
	var created : bool = false
	var _lobby_id:int
	var members :Array = []
	var hosting : bool = false
	var p2p_initialized : bool = false
	var last_handshake_attempt : int



	signal member_joined(member: SteamLobbyMember)
	signal member_left(member: SteamLobbyMember)
	signal message_received(message: SteamPacket)

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

	func update_lobby_members():
		var current_members : Array[int] = []
		for i in range(Steam.getNumLobbyMembers(_lobby_id)):
			var id : int = Steam.getLobbyMemberByIndex(_lobby_id, i)
			if id != Steam.getSteamID():
				current_members.append(id)

				var found : bool = false
				for existing in members:
					if existing.id == id:
						found = true
						break
				if not found:
					var name : String = Steam.getFriendPersonaName(id)
					members.append(SteamLobbyMember.new(id, name))
					member_joined.emit(members[-1])
		
		for existing in members:
			if not existing.id in current_members:
				members.erase(existing)
				member_left.emit(existing)


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
		update_lobby_members()

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
		while not p2p_initialized:
			await(SteamSession.wait(0.1))
		var buffer: PackedByteArray = PackedByteArray()
		buffer.append_array(var_to_bytes(data))
		
		if target == 0:
			for member in members:
				Steam.sendP2PPacket(member.id, buffer, Steam.P2P_SEND_RELIABLE, 0)
		else:
			Steam.sendP2PPacket(target, buffer, Steam.P2P_SEND_RELIABLE, 0)
			
	func _send_handshake():
		var buffer: PackedByteArray = PackedByteArray()
		buffer.append_array(var_to_bytes({"message":"handshake_request", "from":Steam.getSteamID()}))
		for member in members:
				Steam.sendP2PPacket(member.id, buffer, Steam.P2P_SEND_RELIABLE, 0)
		last_handshake_attempt = Time.get_ticks_msec()
				
	func _confirm_handshake():
		var buffer: PackedByteArray = PackedByteArray()
		buffer.append_array(var_to_bytes({"message":"handshake_ack", "from":Steam.getSteamID()}))
		for member in members:
				Steam.sendP2PPacket(member.id, buffer, Steam.P2P_SEND_RELIABLE, 0)

	func _read_p2p_packet() -> SteamPacket:
		var buffer: PackedByteArray = PackedByteArray()

		var size: int = Steam.getAvailableP2PPacketSize()
		if size > 0:
			buffer.resize(size)
			var packet: Dictionary = Steam.readP2PPacket(size, 0)
			var data = bytes_to_var(packet['data'])

			return SteamPacket.new(packet['steam_id_remote'], data)
		else:
			return SteamPacket.new(0,{})

	func _process(_delta:float):
		var p = _read_p2p_packet()
		if 'message' in p.data:
			if p.data['message'] == 'handshake_request':
				_confirm_handshake()
				print("Handshake Request from " + str(p.sender_id) + " received, acknowledgement sent")
			elif p.data['message'] == 'handshake_ack':
				p2p_initialized = true
				print("Handshake Acknowledgement from " + str(p.sender_id) + " received, p2p initialized")
		elif p.sender_id != 0:
			message_received.emit(p)

		if not p2p_initialized and len(members) > 0 and created and Time.get_ticks_msec() - last_handshake_attempt > 10000:
			print("P2P not initialized, sending handshake request")
			_send_handshake()

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
