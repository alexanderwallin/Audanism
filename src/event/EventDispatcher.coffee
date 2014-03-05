###
	Event dispatcher. Gets rid of context issues.
###
class EventDispatcher

	constructor: () ->

	on: (eventName, callback, context) ->
		if context
			callback.bind context
		
		$(document).on eventName, (e) =>
			callback.apply null, arguments.slice(1)

	listen: (eventName, listener, callback) ->
		$(document).on eventName, (e) =>
			callback.call listener, arguments[1]

	trigger: (eventName, args) ->
		$(document).trigger eventName, args



window.Audanism.Event.EventDispatcher = EventDispatcher

# Global "singleton"
window.EventDispatcher = new EventDispatcher()