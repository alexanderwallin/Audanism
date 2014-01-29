/*
	A node cell
*/
NodeCell {

	*new { arg factorType, factorValue;
		^super.new.init(factorType, factorValue);
	}

	init { arg factorType, factorValue;
		this.factorType = factorType;
		this.factorValue = factorValue;
	}

	addFactorValue { arg value;
		var newVal = this.factorValue + value;
		newVal = if (newVal > 100, { 100 }, { newVal });
		newVal = if (newVal < 0, { 0 }, { newVal });
		^newVal;
	}

}