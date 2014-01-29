/*
	GUI super class
*/
GUI {

	// Constructor
	constructor {
		this.$factorsWrap = $('#factors')
		this.$nodesWrap = $('#nodes')

		this._renderedFactors = false
		this._renderedNodes = false

		this._setupControls()

		if google?
			google.setOnLoadCallback =>
				this.$disharmonyChart = $("#disharmony-chart")
				this.disharmonyChart = new google.visualization.LineChart this.$disharmonyChart.get 0;

	_setupControls {
		$('#controls .btn').click (e) =>
			$(document).trigger "dm#{ $(e.currentTarget).attr('href').replace("#", "") }"

	update { arg factors, nodes, tableData;
		this._updateFactors factors
		this._updateNodes nodes
		this._drawCharts tableData

	_drawCharts { arg tableData;
		return if not this.disharmonyChart?
		
		tableData.unshift ['Iteration', 'Sum dish.', 'Actual dish.']


		data = google.visualization.arrayToDataTable tableData

		options =
			title: 'Disharmony chart'
			//hAxis:
			//	viewWindowMode: 'explicit'
			//	viewWindow:
			//		max: 300
			vAxis:
				viewWindowMode: 'explicit'
				viewWindow:
					min: 0


		this.disharmonyChart.draw data, options

	_updateFactors { arg factors;
		if not this._renderedFactors
			this._buildFactors factors
		else
			for factor in factors
				$(".factor[data-factor-type='#{ factor.factorType }']")
					.attr('data-factor-disharmony', factor.disharmony)
					.attr('data-factor-name', factor.name)
					.find('.factor-value').html(factor.factorValue)

	_buildFactors { arg factors;
		// for factor in factors

		factorsHtml = ("<div class=\"factor\" data-factor-type=\"#{ factor.factorType }\"><span class=\"factor-name\">#{ factor.name }</span> <span class=\"factor-value\">#{ factor.factorValue }</span></div>" for factor in factors).join ""
		this.$factorsWrap.html factorsHtml
		this._renderedFactors = true

	_updateNodes { arg nodes;
		if not this._renderedNodes
			this._buildNodes nodes
		else
			for node in nodes
				$node = this.$nodesWrap.find(".node[data-node-id=#{ node.nodeId }]")
				for cell in node.getCells()
					$node.find(".node-cell[data-cell-factor='#{ cell.factorType }']").html(cell.factorValue)

	_buildNodes { arg nodes;
		for node in nodes
			cellsHtml = ("<li class=\"node-cell\" data-cell-factor=\"#{ cell.factorType }\">#{ cell.factorValue }</li>" for cell in node.getCells()).join ""
			cellsHtml = "<ul class=\"node-cells\">#{ cellsHtml }</ul>";
			nodeHtml = "<div class=\"node\" data-node-id=\"#{ node.nodeId }\">#{ cellsHtml }</div>"
			this.$nodesWrap.append nodeHtml

		this._renderedNodes = true


