
pushMany = (arr, objects) ->
	arr.push obj for obj in objects

window.pushMany = pushMany

getRandomElements = (arr, numElements) ->
	#console.log "#getRandomElements", arr, numElements
	copy = (obj for obj in arr)
	elements = (copy.splice(Math.floor(Math.random() * copy.length), 1)[0] for i in [1..numElements])

window.getRandomElements = getRandomElements

Array.prototype.shuffle = () ->
	counter = @length
	temp
	index

	# While there are elements in the array
	while counter > 0

		# Pick a random index
		index = Math.floor(Math.random() * counter)

		# Decrease counter by 1
		counter--;

		# And swap the last element with it
		temp = @[counter]
		@[counter] = @[index]
		@[index] = temp

	return @