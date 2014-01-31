###
	Event dispatcher. Gets rid of context issues.
###
class EventDispatcher

	constructor: () ->


	listen: (eventName, listener, callback) ->
		$(document).on eventName, (e) =>
			callback.call listener, arguments[1]

	trigger: (eventName, args) ->
		$(document).trigger eventName, args



window.Audanism.Event.EventDispatcher = EventDispatcher
window.EventDispatcher = new EventDispatcher()