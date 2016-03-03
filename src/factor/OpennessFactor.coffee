
Factor = require './Factor.coffee'

console.log Factor

class OpennessFactor extends Factor

	constructor: () ->
		super(Factor.TYPE_OPENNESS)


#window.Audanism.Factor.OpennessFactor = OpennessFactor
module.exports = OpennessFactor
