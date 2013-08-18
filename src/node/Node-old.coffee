
###
Sound
###
class Sound
	@_idCounter: 0

	@NUM_BUCKETS: 2

	@clone: (sound) ->
		soundCopy = new Sound sound.getBucketValues false
		soundCopy.soundId = sound.soundId
		Sound._idCounter--

		soundCopy.$soundEl = sound.$soundEl.clone true

		return soundCopy

	constructor: () ->
		@soundId = Sound._idCounter++

		#console.log "Sound", factorValues
		#@_factorBuckets = (new FactorBucket (Math.floor(Math.random() * 2) + 1), factorValue for factorValue in @_factorValues)

		# i for i in [1..@NUM_BUCKETS]

		@_factorBuckets = (new FactorBucket Math.floor(Math.random() * 2) + 1, Math.round(Math.random() * 100) for i in [1..Sound.NUM_BUCKETS])
		console.log "... factor buckets", @_factorBuckets, FactorBucket, Sound.NUM_BUCKETS

	getBuckets: () ->
		@_factorBuckets

	getBucketValue: (index) ->
		if 0 <= index < @_factorBuckets.length then @_factorBuckets[index].factorValue else -1

	setBucketValue: (index, value) ->
		#console.log "#setBucketValue", index, value
		if 0 <= index < @_factorBuckets.length
			@_factorBuckets[index].factorValue = value

	addBucketValue: (index, addValue) ->
		@setBucketValue index, @getBucketValue(index) + addValue

	getBucketValues: (asString = false) ->
		bucketValues = (factorBucket.factorValue for factorBucket in @_factorBuckets)
		console.log "#getBucketValues", bucketValues
		if asString
			bucketValues.join " " 
		else 
			bucketValues

	getString: () ->
		"##{ @.soundId } {#{ @getBucketValues(true) }}"

	updateSoundEl: () ->
		setTimeout =>
			soundListHtml = ("<li>#{ bucket.factorValue }</li>" for bucket in @_factorBuckets).join ""
			@$soundEl.find('.sound-buckets').html(soundListHtml)

			rgbaArr = (val * 25 for val in @getBucketValues(false)[0..3])
			rgbaStr = rgbaArr.join ","
			@$soundEl.css "background-color", "rgba(#{ rgbaStr })"
		, Organism.TIME_INTERVAL / 2
		


window.Sound = Sound