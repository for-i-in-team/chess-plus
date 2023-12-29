class_name PlayerListItem

extends Node

const SPECTATOR = 2147483647

@export var color_icon : Image
var lobby: ChessLobby
var player: ChessLobby.ChessPlayer

func set_player(_lobby: ChessLobby, _player: ChessLobby.ChessPlayer):
	self.lobby = _lobby
	self.player = _player
	update_display()

func update_display():
	$Username.text = player.name
	
	var select = $ColorSelect
	select.clear()
	select.add_item("Spectator", SPECTATOR)
	select.select(0)
	for color in lobby.board.colors:
		var id = lobby.board.colors.find(color)
		var icon : Image = color_icon.duplicate()
		icon.fill(color.color)
		icon.resize(32,32)
		select.add_icon_item(ImageTexture.create_from_image(icon), color.name, id)
		if color == player.color:
			select.select(select.get_item_index(id))

func leave_game():
	lobby.kick(player.id)

func _on_ColorSelect_item_selected(index):
	var id = $ColorSelect.get_item_id(index)
	if id == SPECTATOR:
		lobby.update_player_color(player.id, null)
	else:
		lobby.update_player_color(player.id, lobby.board.colors[id])

