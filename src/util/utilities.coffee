

randomInt = (lower, upper=0) ->
	start = Math.random()
	if not lower?
		[lower, upper] = [0, lower]
	if lower > upper
		[lower, upper] = [upper, lower]
	return Math.floor(start * (upper - lower + 1) + lower)


logWithBase = (base, num) ->
	return Math.log( num ) / Math.log( base )


###
	Decimal adjustment of a number.

	@param	{String}	type	The type of adjustment.
	@param	{Number}	value	The number.
	@param	{Integer}	exp		The exponent (the 10 logarithm of the adjustment base).
	@returns	{Number}			The adjusted value.
###
decimalAdjust = (type, value, exp) ->
	
	# If the exp is undefined or zero...
	if typeof exp is 'undefined' or +exp is 0
		return Math[type](value)
	value = +value
	exp   = +exp

	# If the value is not a number or the exp is not an integer...
	if isNaN(value) or not (typeof exp is 'number' && exp % 1 is 0)
		return NaN
	
	# Shift
	value = value.toString().split('e')
	value = Math[type](+( value[0] + 'e' + (if value[1] then (+value[1] - exp) else -exp)))
	#value = Math[type]( valueTemp )

	# Shift back
	value = value.toString().split('e')
	return +(value[0] + 'e' + (if value[1] then (+value[1] + exp) else exp))

# Decimal round
if not Math.round10?
	Math.round10 = (value, exp) ->
		return decimalAdjust('round', value, exp)

# Decimal floor
if not Math.floor10?
	Math.floor10 = (value, exp) ->
		return decimalAdjust('floor', value, exp)

# Decimal ceil
if not Math.ceil10?
	Math.ceil10 = (value, exp) ->
		return decimalAdjust('ceil', value, exp)


numberSuffixed = (number, decimalAdjust) ->
	suffix = ''

	if number >= 1000000000
		suffix = 'g'
		number /= 1000000000
	else if number >= 1000000
		suffix = 'm'
		number /= 1000000
	else if number >= 1000
		suffix = 'k'
		number /= 1000

	numAdjusted = Math.round10( number, decimalAdjust )

	return numAdjusted + suffix


module.exports = {
	randomInt
	logWithBase
	decimalAdjust
	numberSuffixed
}
