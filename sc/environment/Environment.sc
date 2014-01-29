/*
	Environment
*/
Environment {

	// The total number of organisms to create
	classvar NUM_ORGANISMS = 1;

	// The time in milliseconds between each iteration
	classvar TIME_INTERVAL = 100;

	// Constructor
	//
	// Creates organisms and interpreters. Initializes the loop and
	// handles core actions in each iteration
	constructor {
		
		this._iterationCount = 0
		this._isRunning = false
		this._isSingleStep = true

		this._organisms = (new Organism for i in [1..Environment.NUM_ORGANISMS])

		this._gui = new GUI

		for organism in this._organisms
			this._gui.update organism.getFactors(), organism.getNodes(), organism.getDisharmonyHistoryData 200

		this.listenToControls()

		this.createInfluenceSources()

		this.run()

	// Initializes the loop
	run {
		this._intervalId = setInterval =>
			this.handleIteration()
		, Environment.TIME_INTERVAL

		this.handleIteration()

	// Starts/resumes the loop
	start {
		this._isRunning = true

	// Pauses the loop
	pause {
		this._isRunning = false

	// Stops the loop
	stop {
		this._isRunning = false
		clearInterval this._intervalId

	// Performs one step of the loop
	step {
		this._isSingleStep = true

	listenToControls {
		$(document).on 'dmstart', (e) =>
			this.start()
		$(document).on 'dmpause', (e) =>
			this.pause()
		$(document).on 'dmstop', (e) =>
			this.stop()
		$(document).on 'dmstep', (e) =>
			this.step()

	// Handles the current iteration by listening to 
	handleIteration {
		this._iterationCount++

		// If running, trigger node comparisons for all organisms
		if this._isRunning or this._isSingleStep
			for organism in this._organisms
				organism.performNodeComparison() 

				this._gui.update organism.getFactors(), organism.getNodes(), organism.getDisharmonyHistoryData 200

				this._isSingleStep = false

	//
	createInfluenceSources {
		this._influenceSources = []

		// Add sources
		this._influenceSources.push new RandomSourceAdapter(this.)

		// Activate sources
		sourceAdapter.activate() for sourceAdapter in this._influenceSources

	//
	influence { arg influenceData;
		return if not this._isRunning


		// Random alteration
		if influenceData.random?

			type = influenceData.random['object']
			argNum = influenceData.random.num
			argVal = influenceData.random.valueModifier

			num = 0
			valueMod = -1

			// Num objects to alter
			numType = typeof argNum
			if numType is 'integer'	then num = argNum
			else if numType is 'array' then num = Math.randomRange argNum[1], argNum[0]
			else if numType is 'string' and argNum is 'rand' 
				num = Math.randomRange(if type is 'factor' then 1 else 5)

			// Apply alteration
			if type is 'factor'
				for organism in this._organisms
					
					// Get factors
					factors = getRandomElements organism.getFactors(), num
					for factor in factors

						// The value to alter
						valType = typeof argVal
						
						if valType is 'integer' 	then valueMod = argVal
						else if valType is 'array'	then valueMod = Math.randomRange argVal[1], argVal[0]
						else if valType is 'string' and argVal is 'rand' 
							valueMod = Math.randomRange 5, -5

						organism.getFactorOfType(factor.factorType).addValue valueMod

			else if type is 'node'
				for organism in this._organisms
					
					// Get factors
					nodes = getRandomElements organism.getNodes(), num
					for node in nodes

						// The value to alter
						valType = typeof argVal
						
						if valType is 'integer' 	then valueMod = argVal
						else if valType is 'array'	then valueMod = Math.randomRange argVal[1], argVal[0]
						else if valType is 'string' and argVal is 'rand' 
							valueMod = Math.randomRange 50, -50

						cell = getRandomElements(node.getCells(), 1)[0]

						cell.addFactorValue valueMod


