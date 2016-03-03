
Instrument = require './Instrument.coffee'
randomInt = require('../../util/utilities.coffee').randomInt

###
	PercArpeggiator
###

class PercArpeggiator extends Instrument

	constructor: (@instrumentsIn, @frequency, @shuffleAmount) ->
		super(@instrumentsIn, 'MonoistPerc', true)

		@frequency     ?= 1
		@shuffleAmount ?= 0.333
		@fixedShuffle   = false
		@intervalTime = 1 / @frequency

		@midNote        = 80
		@noteSpread     = 60
		
		@interval       = null
		@count          = 0
		@isRunning      = false
		@shouldRestart  = false

		@hpfVal = 0
		@lpfVal = 20000

		###
		window.addEventListener 'mousemove', (e) =>
			@hpfVal = (e.pageX / window.innerWidth) * 2000
			@lpfVal = 20000 - (e.pageY / window.innerHeight) * 20000
			console.log(@hpfVal, @lpfVal)
		###


	setFrequency: (@frequency) ->
		@intervalTime = 1 / @frequency
		@shouldRestart = true

	beforeCreateVoice: (note) ->

		if (@voices[note])
			#console.log(' ,,,, KILL PERC NOTE', note)
			#@voices[note].stop( 0 )
			@voices[note] = null

	setupVoice: (voice) ->

		# Random pan
		voice.pan.setPosition( 1 - Math.random() * 2, 0, 1 - Math.random() * 2 )

		# Shuffle
		voice.waitTime = if @count % 2 == 0 or (not @fixedShuffle && randomInt(0, 1) == 0) then @shuffleAmount * @intervalTime else 0

		# EQ
		voice.hpf.frequency.value = @hpfVal
		voice.lpf.frequency.value = @lpfVal

		# Modulation
		voice.modGain2.gain.value = 0.5 * (1 + Math.sin(@count / (@intervalTime * 100) - Math.PI / 2)) * voice.modGain2.gain.value
		#console.log(' === GAIN:', voice.modGain2.gain.value)

		# Gain
		voice.masterVol.gain.value = 0.3

	start: () ->

		@isRunning = true
		#@hit()

		# Stop ongoing interval
		if @interval
			@stop()

		# Start new interval
		@interval = setInterval () =>
			@count++

			# Hit note
			@hit() #@noteOn( @midNote - randomInt(0, @noteSpread) )

		, @intervalTime * 1000
		
	
	stop: () ->

		@isRunning = false

		clearInterval( @interval )
		@interval = null

	hit: () ->

		# Timed restart
		if @shouldRestart
			#console.log('restart')
			@stop()
			@start()
			@shouldRestart = false

		else
			@noteOn( @midNote - randomInt(0, @noteSpread) )
		
		@count++

	onNoteOn: (note) ->
		@count++

	onNoteOff: (note) ->
		#if @isRunning
		#	@hit()



module.exports = PercArpeggiator

