/*
	Factor
*/
Factor {

	// Factor types
	classvar TYPE_UNKNOWN = 0;
	classvar TYPE_OPENNESS = 1;
	classvar TYPE_CONSCIENTIOUSNESS = 2;
	classvar TYPE_EXTRAVERSION = 3;
	classvar TYPE_AGREEABLENESS = 4;
	classvar TYPE_NEUROTICISM = 5;

	// Factor correlations. Duplicate matrix entries are commented out.
	this.FACTOR_CORRELATIONS:
		'1': # Openness
			'2': -15
			'3': 25
		'2': # Conscientiousness
			//1: -15
			'3': 30
		'3': # Extraversion
			//1: 25
			//2: 30
			'4': 50
		'4': # Agreeableness
			//3: 50
			'5': -20
		//5: # Neuroticism
			//4: -20


	*createFactor { arg factorType, factorValue = 0;
		switch factorType
			when Factor.TYPE_OPENNESS then new OpennessFactor()
			when Factor.TYPE_CONSCIENTIOUSNESS then new ConscientiousnessFactor()
			when Factor.TYPE_EXTRAVERSION then new ExtraversionFactor()
			when Factor.TYPE_AGREEABLENESS then new AgreeablenessFactor()
			when Factor.TYPE_NEUROTICISM then new NeuroticismFactor()
			else null

	// Constructor
	constructor { arg factorType, factorValue = 0;
		this.factorType = factorType;
		this.factorValue = factorValue;

		// Meta
		this.name = this.constructor.name.replace /^(\w+)Factor$/, "$1"

		// Disharmony states
		this.disharmony = 0
		this.relativeDisharmony = []

	addValue { arg value;
		this.factorValue += value
		this.factorValue = 0 if this.factorValue < 0
		this.factorValue = 100 if this.factorValue > 100

	toString {
		"<Factor ##{ this.factorType } (#{ this.name }); factorValue = #{ this.factorValue }>"

