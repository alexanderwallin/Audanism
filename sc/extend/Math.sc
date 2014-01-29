
	if not max? and not min?
		return Math.random()

	min = 0 unless min?

	return min + Math.floor (Math.random() * (max - min + 1))