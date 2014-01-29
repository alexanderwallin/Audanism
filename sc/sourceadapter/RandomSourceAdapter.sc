/*
	Alters the factor and/or node values randomly
*/
class RandomSourceAdapter extends SourceAdapter

	classvar TIME_INTERVAL_ALTER_FACTORS = 500;
	classvar PROBABILITY_ALTER_FACTORS = 0.1;

	classvar TIME_INTERVAL_ALTER_NODES = 500;
	classvar PROBABILITY_ALTER_NODES = 0.2;

	constructor { arg listener;
		this.listener = listener;
		super(this.listener)



	// Activates the source adapter. 
	activate {
		setInterval () =>
			this.tryAlterFactors()
		, RandomSourceAdapter.TIME_INTERVAL_ALTER_FACTORS

		setInterval () =>
			this.tryAlterNodes()
		, RandomSourceAdapter.TIME_INTERVAL_ALTER_NODES

	// Adapts/translates the source data into data that the environment
	// understands.
	getAdaptedSourceData { arg sourceData;
		sourceData

	// 
	tryAlterFactors {

		// Probability check
		if Math.floor((Math.random() + 1) / RandomSourceAdapter.PROBABILITY_ALTER_FACTORS) is 1

			// Let the listener take care of which objects should me modified
			// and by how much
			this.triggerInfluence {
				'random': {
					'object': 'factor'
					'num': 1
					'valueModifier': 'rand'
				}
			}

	//
	tryAlterNodes {

		// Probability check
		if Math.randomRange(Math.round(1 / RandomSourceAdapter.PROBABILITY_ALTER_NODES)) is 1

			// Let the listener take care of which objects should me modified
			// and by how much
			this.triggerInfluence {
				'random': {
					'object': 'node'
					'num': 'rand'
					'valueModifier': 'rand'
				}
			}



