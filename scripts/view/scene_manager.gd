class_name SceneManager

extends Node

const SCENE_LOAD_DELAY : float = 0.3


func load_scene(scene:Scene):
	get_tree().change_scene_to_packed(scene.get_packed_scene())

	while !scene.is_scene_ready(get_tree()):
		await(get_tree().create_timer(SCENE_LOAD_DELAY).timeout)

	scene.on_scene_loaded(get_tree())




class Scene:
	
	func load_scene():
		SceneManagerInstance.load_scene(self)

	func get_packed_scene() -> PackedScene:
		assert(false, "get_packed_scene is not implemented")
		return null

	func is_scene_ready(_tree:SceneTree) -> bool:
		return true

	func on_scene_loaded(_tree:SceneTree):
		pass
