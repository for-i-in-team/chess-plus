class_name Utils

class AsyncSignal:
	signal _base(instance:_AsyncSignalInstance, args:Array)
	var running: Dictionary = {}
	var name:String

	func _init(_args:Array):
		name = _args[0]

	func connect_sig(fn:Callable):
		var inner_fn : Callable = func(instance:_AsyncSignalInstance, args:Array):
			await(fn.callv(args))
			instance.complete.emit()
		_base.connect(inner_fn)

	func emit(args:Array):
		var instance : _AsyncSignalInstance = _AsyncSignalInstance.new()
		await(instance.emit(args, len(_base.get_connections()), func(instance:_AsyncSignalInstance, args:Array):
			_base.emit(instance, args)
		))



class _AsyncSignalInstance:
	signal complete()

	signal all_complete()
	var running:int = 0

	func emit(args:Array, num_listeners:int, callback:Callable):
		running = num_listeners
		track_completion()
		callback.call(self, args)
		await(is_complete())

	func is_complete():
		if running != 0:
			await(all_complete)

	func track_completion():
		while running > 0:
			await(complete)
			running -= 1
		all_complete.emit()

static func recursive_to_dict(object:Variant):
	var dict = inst_to_dict(object)
	var output = Dictionary()

	var ignored_keys : Array[String] = []
	if object.has_method("get_ignored_keys"):
		ignored_keys = object.get_ignored_keys()

	for key in dict:
		if key in ignored_keys:
			continue

		if dict[key] is Object:
			output[key+"__recursed__"] = recursive_to_dict(dict[key])
		elif dict[key] is Array:
			var array:Array = dict[key]
			var new_array = []
			for i in range(array.size()):
				if array[i] is Object:
					new_array.append(recursive_to_dict(array[i]))
				else:
					new_array.append(array[i])
			output[key] = new_array
		elif dict[key] is Dictionary:
			output[key] = recursive_to_dict(dict[key])
		else:
			output[key] = dict[key]

	return output

static func recursive_from_dict(dict:Dictionary):
	for key in dict:
		if key.ends_with("__recursed__"):
			dict[key.replace("__recursed__", "")] = recursive_from_dict(dict[key])
		elif dict[key] is Array:
			var array:Array = dict[key]
			var new_array = []
			for i in range(array.size()):
				if array[i] is Dictionary:
					new_array.append(recursive_from_dict(array[i]))
				else:
					new_array.append(array[i])
			dict[key] = new_array
		elif dict[key] is Dictionary:
			dict[key] = recursive_from_dict(dict[key])
	
	var inst = dict_to_inst(dict)

	if inst.has_method("on_deserialize"):
		inst = inst.on_deserialize()

	return inst
