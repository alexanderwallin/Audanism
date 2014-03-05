
# Source hierarchy
window.Audanism = {
	'Audio': {
		'FX':          {}
		'Instrument':  {}
		'Module':      {}
		'Synthesizer': {}
	}
	'Calculator':    {}
	'Environment':   {}
	'Event':         {}
	'Factor':        {}
	'Graphic':       {}
	'GUI':           {}
	'Node':          {}
	'SourceAdapter': {}
	'Util':          {}
}


# Initialize environment
$(window).ready =>
	window.Audanism.appInstance = new Audanism.Environment.Environment