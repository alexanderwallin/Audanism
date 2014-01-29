
pushMany = (arr, objects) ->
	arr.push obj for obj in objects



getRandomElements = (arr, numElements) ->
	copy = (obj for obj in arr)
	elements = (copy.splice(Math.floor(Math.random() * copy.length), 1)[0] for i in [1..numElements])

