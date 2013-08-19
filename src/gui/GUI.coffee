###
	GUI super class
###
class GUI

	# Constructor
	constructor: () ->
		@$factorsWrap = $('#factors')
		@$nodesWrap = $('#nodes')

		@_renderedFactors = false
		@_renderedNodes = false

		@_setupControls()

		if google?
			google.setOnLoadCallback =>
				@$disharmonyChart = $("#disharmony-chart")
				@disharmonyChart = new google.visualization.LineChart @$disharmonyChart.get 0;
				#console.log 'google.setOnLoadCallback', @disharmonyChart

	_setupControls: () ->
		$('#controls .btn').click (e) =>
			$(document).trigger "dm#{ $(e.currentTarget).attr('href').replace("#", "") }"

	update: (factors, nodes, tableData) ->
		@_updateFactors factors
		@_updateNodes nodes
		@_drawCharts tableData

	_drawCharts: (tableData) ->
		return if not @disharmonyChart?
		
		tableData.unshift ['Iteration', 'Disharmony']

		data = google.visualization.arrayToDataTable tableData

		options =
			title: 'Disharmony chart'
			#hAxis:
			#	viewWindowMode: 'explicit'
			#	viewWindow:
			#		max: 300
			vAxis:
				viewWindowMode: 'explicit'
				viewWindow:
					min: 0

		#console.log "@drawCharts --- stateHistory:", @stateHistory, "data:", data

		@disharmonyChart.draw data, options

	_updateFactors: (factors) ->
		if not @_renderedFactors
			@_buildFactors factors
		else
			for factor in factors
				$(".factor[data-factor-type='#{ factor.factorType }']")
					.attr('data-factor-disharmony', factor.disharmony)
					.attr('data-factor-name', factor.name)
					.find('.factor-value').html(factor.factorValue)

	_buildFactors: (factors) ->
		# for factor in factors

		factorsHtml = ("<div class=\"factor\" data-factor-type=\"#{ factor.factorType }\"><span class=\"factor-name\">#{ factor.name }</span> <span class=\"factor-value\">#{ factor.factorValue }</span></div>" for factor in factors).join ""
		@$factorsWrap.html factorsHtml
		@_renderedFactors = true

	_updateNodes: (nodes) ->
		if not @_renderedNodes
			@_buildNodes nodes
		else
			for node in nodes
				$node = @$nodesWrap.find(".node[data-node-id=#{ node.nodeId }]")
				for cell in node.getCells()
					$node.find(".node-cell[data-cell-factor='#{ cell.factorType }']").html(cell.factorValue)

	_buildNodes: (nodes) ->
		for node in nodes
			cellsHtml = ("<li class=\"node-cell\" data-cell-factor=\"#{ cell.factorType }\">#{ cell.factorValue }</li>" for cell in node.getCells()).join ""
			cellsHtml = "<ul class=\"node-cells\">#{ cellsHtml }</ul>";
			nodeHtml = "<div class=\"node\" data-node-id=\"#{ node.nodeId }\">#{ cellsHtml }</div>"
			@$nodesWrap.append nodeHtml

		@_renderedNodes = true


window.GUI = GUI