###
	Pink noise
###
class NoisePink extends Audanism.Audio.Instrument.Instrument

	constructor: (@instrumentsIn) ->
		super( @instrumentsIn, null, false )

		@createNoise()

	createNoise: () ->
		bufferSize = 4096

		_createPinkNoiseNode = () ->
			b0
			b1
			b2
			b3
			b4
			b5
			b6
			b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0
			 
			node = Audanism.Audio.audioContext.createScriptProcessor( bufferSize, 1, 1 )
			node.onaudioprocess = (e) =>
				output = e.outputBuffer.getChannelData(0)

				for i in [0..bufferSize-1]
					white = Math.random() * 2 - 1
					b0 = 0.99886 * b0 + white * 0.0555179
					b1 = 0.99332 * b1 + white * 0.0750759
					b2 = 0.96900 * b2 + white * 0.1538520
					b3 = 0.86650 * b3 + white * 0.3104856
					b4 = 0.55000 * b4 + white * 0.5329522
					b5 = -0.7616 * b5 - white * 0.0168980
					output[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362
					output[i] *= 0.11 # (roughly) compensate for gain
					b6 = white * 0.115926

			return node

		# Noise volume
		@noiseVol            = Audanism.Audio.audioContext.createGain()
		@noiseVol.gain.value = 0.1

		# Noise LPF
		@noiseLpf                 = Audanism.Audio.audioContext.createBiquadFilter()
		@noiseLpf.type            = 'lowpass'
		@noiseLpf.frequency.value = 10000

		# Create noise node
		@noise = _createPinkNoiseNode()

		# Connect
		@noise.connect( @noiseLpf )
		@noiseLpf.connect( @noiseVol )
		@noiseVol.connect( @instrumentsIn )

	start: () ->
		@noiseVol.gain.value = 0.1

	stop: () ->
		@noiseVol.gain.value = 0

	setLpfFrequency: (frequency) ->
		@noiseLpf.frequency.value = frequency




window.Audanism.Audio.Instrument.NoisePink = NoisePink
