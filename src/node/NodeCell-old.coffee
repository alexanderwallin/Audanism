
###
FactorBucket
###
class FactorBucket

	constructor: (factorType, factorValue) ->
		console.log "FactorBucket", factorType, factorValue
		@factorType = factorType
		@factorValue = factorValue


window.FactorBucket = FactorBucket