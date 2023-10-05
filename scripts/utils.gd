class_name Utils

class AsyncSignal:
	signal _base(instance:_AsyncSignalInstance, args:Array)
	signal _complete(id:int)
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
