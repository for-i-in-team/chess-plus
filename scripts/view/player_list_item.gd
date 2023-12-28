class_name PlayerListItem

extends Node

@export var color_icon : Image
var lobby: ChessLobby
var player: ChessLobby.ChessPlayer

func set_player(_lobby: ChessLobby, _player: ChessLobby.ChessPlayer):
	self.lobby = _lobby
	self.player = _player
	update_display()

func update_display():
	$Username.text = player.name
	
	$ColorSelect.clear()
	for color in lobby.board.colors:
		var id = lobby.board.colors.find(color)
		var icon : Image = color_icon.duplicate()
		icon.fill(color.color)
		icon.resize(32,32)
		$ColorSelect.add_icon_item(ImageTexture.create_from_image(icon), color.name, id)
		if color == player.color:
			$ColorSelect.select(id)

func leave_game():
	lobby.kick(player.id)

func _on_ColorSelect_item_selected(id):
	lobby.update_player_color(player.id, lobby.board.colors[id])
