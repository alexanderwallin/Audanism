/*
	Source adapter super class.

	A source adapater listens to any type of outer data feed
	and adapts it to data interpretable to the environment.
*/
SourceAdapter {

	constructor { arg listener;
		this.listener = listener;

	// Activates the source adapter. 
	activate {

	// Adapts/translates the source data into data that the environment
	// understands.
	getAdaptedSourceData { arg sourceData;
		influenceData =
			'factors': [{
				'factor': null
				'valueModifier': null
				// 'factorExtension': {}
			}]
			'nodes': [{
				'node': null
				'factorType': null
				'valueModifier': 0
				// 'nodeModifier': {}
			}]
			'random': [{
				'object': 'node' # 'factor'
				'num': [0, 1] # 123, 'rand'
				'valueModifier': [0, 1] # 123, 'rand'
			}]
		

	// Notifies the listener about the outer influence brought on by
	// the source.
	triggerInfluence { arg influenceData;
		this.listener.influence influenceData if this.listener.influence?
