###
	EventDispatcher

	The event dispatcher is an abstraction of jQuery's event dispatchment.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###
class EventDispatcher

	constructor: () ->

	# 
	# Binds an event to a handler, where the handler is possibly bound 
	# to a given this context.
	#
	on: (eventName, callback, context) ->
		if context
			callback.bind context
		
		$(document).on eventName, (e) =>
			callback.apply null, arguments.slice(1)

	listen: (eventName, listener, callback) ->
		$(document).on eventName, (e) =>
			callback.call listener, arguments[1]

	# 
	# Triggers an event with the given arguments.
	#
	trigger: (eventName, args) ->
		$(document).trigger eventName, args



window.Audanism.Event.EventDispatcher = EventDispatcher

# Global "singleton"
window.EventDispatcher = new EventDispatcher()