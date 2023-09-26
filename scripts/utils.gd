class_name Utils

class AsyncSignal:
	signal _base(id:int, args:Array)
	signal _complete(id:int)
	var running :Dictionary = {}

	func _init(_args:Array):
		pass

	func connect_sig(fn:Callable):
		var inner_fn : Callable = func(id: int, args:Array):
			await(fn.callv(args))
			_complete.emit(id)
		_base.connect(inner_fn)

	func emit(args:Array):
		var id = randi()
		print(Time.get_unix_time_from_system (), ": ", "Emit Start ", id)
		running[id] = len(_base.get_connections())
		check_completion(id)
		_base.emit(id, args)
		await(check_completion(id))
		print(Time.get_unix_time_from_system (), ": ", "Emit End ", id)

	func check_completion(id:int):
		while running[id] > 0:
			var event_id = await(_complete)
			if id == event_id:
				running[id] -= 1