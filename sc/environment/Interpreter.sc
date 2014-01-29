/*
	Interpreter
*/
Interpreter {

	// Constructor
	constructor { arg sourceAdapters;
		this.sourceAdapters = sourceAdapters;

	// Adds a source adapter
	addSourceAdapter { arg sourceAdapter;

	// Tells the interpreter to start listening to its sources.
	// When sources bring alterations, an event with information 
	// about the alteration is triggered.
	startListenToSources {


