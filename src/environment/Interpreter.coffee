###
	Interpreter
###
class Interpreter

	# Constructor
	constructor: (@sourceAdapters) ->

	# Adds a source adapter
	addSourceAdapter: (sourceAdapter) ->

	# Tells the interpreter to start listening to its sources.
	# When sources bring alterations, an event with information 
	# about the alteration is triggered.
	startListenToSources: () ->


window.Audanism.Environment.Interpreter = Interpreter