###
	WebGL organism visualizer
###
class VisualOrganism


	# Constructor
	constructor: () ->
		_this = @

		# Options
		@opts = {
			'cameraDistanceStart': 1300
			'cameraDistance':      1300
			'clusterSize':         500

			'roomSize':            2000
			'roomVertices':        200
			'roomColor':           new THREE.Color(0x3AAB92)
			'roomColorChaos':      new THREE.Color(0x941950)

			'fogColorStart':       new THREE.Color(0x999999)

			'ballSize':            10
			'ballColor':           new THREE.Color(0xF2ED50)
			'ballColorCompare':    new THREE.Color(0xED8A34)
			'ballCompareTime':     1000
			'ballColorInfluence':  new THREE.Color(0xED34A0)
			'ballInfluenceTime':   2000
		}

		# Init handlers
		EventDispatcher.listen 'audanism/init/organism',  @, @onInitOrganism

		# Real-time handlers
		EventDispatcher.listen 'audanism/iteration',      @, @onIteration
		EventDispatcher.listen 'audanism/influence/node', @, @onInfluenceNode
		EventDispatcher.listen 'audanism/compare/nodes',  @, @onCompareNodes

		@initControls()

		#$('html').addClass 'canvas-only'


	# Handles organism init
	onInitOrganism: (organism) ->
		console.log '#onInitOrganism', organism, @
		@organism = organism

		@init()


	# Initialzer
	init: () ->

		# Make the animate() functions public
		window.Audanism.Graphic.public = {
			'animate': @animate.bind(@)
		}

		@buildScene()
		@animate()


	# Builds the WebGL scene
	buildScene: () ->
		console.log '#buildScene'

		# Essentials
		@camera
		@scene
		@renderer
		
		# Lights
		@lightAmb
		@lightSpot
		
		# Balls
		@balls       = []
		@balls3d     = []
		@numBalls    = @organism.getNodes().length
		@sphereSize  = 500
		
		# Frame count
		@frame       = 0
		
		# Mouse states
		@mouseX      = 0
		@mouseY      = 0
		@mouseStartX = 0
		@mouseStartY = 0
		@mouseDX     = 0
		@mouseDY     = 0
		@mouseDown   = false
		
		# Keyboard states
		@keyLeft     = false
		@keyRight    = false
		@keyUp       = false
		@keyDown     = false


		# --- Start creating --- #


		# Camera && scene
		@camera = new THREE.PerspectiveCamera 50, window.innerWidth / window.innerHeight, 1, 10000
		@camera.position = new THREE.Vector3( 1, 0.25, 1 ).multiplyScalar( @opts.cameraDistanceStart )
		@camera.target = new THREE.Vector3 0, 0, 0
		@camera.lookAt @camera.target
		@camera.setLens 35

		@scene = new THREE.Scene()
		@scene.fog = new THREE.Fog( 0x999999, @opts.clusterSize / 2, @opts.clusterSize * 12 )

		# Container sphere
		@room = new THREE.Mesh( new THREE.SphereGeometry(@opts.roomSize, @opts.roomVertices, @opts.roomVertices), new THREE.MeshPhongMaterial({ 'ambient': @opts.roomColor, 'side': THREE.BackSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors }) )
		@scene.add @room

		# Make balls
		for i in [0..@numBalls-1]

			# Make ball info object
			ball = {
				ballId:     i
				hello:      "hello. i am ball no #{ i }."
				direction:  new THREE.Vector3 (2 * Math.random() - 1), (2 * Math.random() - 1), (2 * Math.random() - 1)
				ballSize:   @opts.ballSize
			}

			# Set ball position from direction
			ball.pos = new THREE.Vector3 (ball.direction.x * Math.random() * @opts.clusterSize), (ball.direction.y * Math.random() * @opts.clusterSize), (ball.direction.z * Math.random() * @opts.clusterSize)

			if i is 0
				console.log '>> ball', ball
				console.log '>> ball start at', ball.pos

			# Make ball 3d object
			ballGeometry  = new THREE.SphereGeometry ball.ballSize, 20, 20
			ballMaterial  = new THREE.MeshLambertMaterial({ 'ambient':@opts.ballColor, 'side': THREE.DoubleSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors })
			ball3d        = new THREE.Mesh ballGeometry, ballMaterial
			ball3d.ballId = ball.ballId; # Store id reference

			# Store ball 3d object in ball info object
			ball.ball3d   = ball3d

			# Position ball
			ball.ball3d.position = ball.pos.clone()

			console.log ball.pos
			@scene.add ball.ball3d
			@balls[i] = ball

		console.log @balls

		# Create a plane
		#planeXZ = new THREE.Mesh( new THREE.PlaneGeometry @opts.clusterSize * 3, @opts.clusterSize * 3, new THREE.MeshLambertMaterial { 'color':0x22eecc, 'side': THREE.DoubleSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors } )
		#planeXZ.position.set 0, 0, 0
		#@scene.add planeXZ

		# Add lights
		@lightAmb = new THREE.AmbientLight 0xffffff
		@scene.add @lightAmb

		@lightSpot = new THREE.DirectionalLight 0xffffff, 0.2
		@lightSpot.position.set 0, 1, 1
		@scene.add @lightSpot

		# Add axises
		@axis = new THREE.AxisHelper( 500 )
		@scene.add @axis

		# Renderer
		@renderer = new THREE.WebGLRenderer { 'alpha':false, 'antialias':true }
		#renderer.setClearColor( 0x000000, 0 )
		@renderer.setSize window.innerWidth, window.innerHeight

		console.log @scene

		$('#container').append @renderer.domElement


	# Animate
	animate: () ->

		# note: three.js includes requestAnimationFrame shim
		requestAnimationFrame( Audanism.Graphic.public.animate )

		@frame++

		# Rotate camera around cluster
		@camera.position.x = Math.sin(  @frame / 200 ) * @opts.cameraDistance # + (Math.sin( @frame / 100) * @opts.clusterSize / 10)
		@camera.position.z = Math.cos(  @frame / 200 ) * @opts.cameraDistance # + (Math.sin( @frame / 100) * @opts.clusterSize / 10)
		@camera.lookAt( @camera.target )

		TWEEN.update()

		# Render
		@renderer.render( @scene, @camera )


	# Sets up manual controls
	initControls: () ->

		_this = @

		$(document).on 'keydown', (e) =>
			switch e.which
				when 37 then _this.keyLeft  = true
				when 38 then _this.keyUp    = true
				when 39 then _this.keyRight = true
				when 40 then _this.keyDown  = true

		$(document).on 'keyup', (e) =>
			switch e.which
				when 37 then _this.keyLeft  = false
				when 38 then _this.keyUp    = false
				when 39 then _this.keyRight = false
				when 40 then _this.keyDown  = false


	# Handles an organism iteration
	onIteration: (organism) ->
		console.log '#onIteration'

		disharmony = organism.getDisharmonyHistoryData()
		if disharmony.length == 0
			return

		disharmony = disharmony[disharmony.length - 1]

		if not @opts.initialDisharmonyData?
			@opts.initialDisharmonyData = disharmony
			console.log 'stored initial disharmony', disharmony

		relativeDisharmony = disharmony[2] / @opts.initialDisharmonyData[2]

		@largestDistance = 0

		# Set balls distance from center depending on the organism's state
		for ball in @balls

			# Tween the ball
			newPos = ball.pos.clone().multiplyScalar relativeDisharmony
			tweenFrom = ball.ball3d.position.clone()
			tweenTo   = { 'x':newPos.x, 'y':newPos.y, 'z':newPos.z } # newPos.clone()

			@_tweenBall ball, tweenFrom, tweenTo

			# Store furthest position if this is that
			if (ball.ball3d.position.length() > @largestDistance)
				@largestDistance = ball.ball3d.position.length()

		# Move camera according to the ball furthest out
		@_tweenCameraDistance @largestDistance * (@opts.cameraDistanceStart / @opts.clusterSize)

		# Tween fog
		latestDisharmonyBlock = organism.getDisharmonyHistoryData().slice(-10)

		disharmonySum = 0
		(disharmonySum += dish[2] for dish in latestDisharmonyBlock)
		disharmonyAvg = disharmonySum / latestDisharmonyBlock.length

		#latestDisharmonyChange = latestDisharmonyBlock[latestDisharmonyBlock.length - 1][2] / latestDisharmonyBlock[0][2]
		latestDisharmonyChange = latestDisharmonyBlock[latestDisharmonyBlock.length - 1][2] / disharmonyAvg

		###
		console.log 'fog color start:', @opts.fogColorStart
		console.log 'latestDisharmonyBlock', latestDisharmonyBlock
		console.log 'latestDisharmonyChange', latestDisharmonyChange
		console.log 'color scalar', (1 + (1 - latestDisharmonyChange))
		newFogColor = @opts.fogColorStart.clone().multiplyScalar 0.2 * (1 + (1 - latestDisharmonyChange))
		console.log 'new fog color', newFogColor
		@_tweenColor @scene.fog.color, @scene.fog.color, newFogColor, 400
		###

		# Change room color
		#console.log 'latest disharmony change', latestDisharmonyChange
		#@_tweenColor @room.material.ambient, @opts.roomColor, @opts.roomColor.clone().lerp( @opts.roomColorChaos, 1 - Math.pow(latestDisharmonyChange, 2) ), 100


		# Change ball size depending on factor disharmonies
		for node in @organism.getNodes()
			cells = node.getCells()
			#factorDisharmonySum = @organism.getFactorOfType(cell.factorType) for cell in cells

			###

			Relative changes to a node from its cells' factors' current conditions

			factorsConditionSum = 0
			factorsRelConditionSum = 0

			for cell in cells

				# Get the cell's factor's latest history
				factorDisharmonyHistory = @organism.getFactorOfType(cell.factorType).disharmonyHistory
				factorLatestHistory = factorDisharmonyHistory.slice(-10)
				console.log '··· factor history', factorLatestHistory

				# Total disharmony over this period
				factorDisharmonySum = factorDisharmonySum + hist for hist in factorLatestHistory
				console.log('··· factorDisharmonySum', factorDisharmonySum)

				# Calculate the factor's average dishamonry over this period
				factorDisharmonyAvg = factorDisharmonySum / factorLatestHistory.length
				console.log '··· factorDisharmonyAvg', factorDisharmonyAvg

				# Calculate the factor's current condition relative the average disharmony
				factorCurrCondition = factorLatestHistory[factorLatestHistory.length - 1] / factorDisharmonyAvg
				console.log '··· factorCurrCondition', factorCurrCondition

				# Add it to the sum of current conditions
				factorsRelConditionSum += factorCurrCondition
				

			#factorConditionAvg = factorConditionsSum / cells.length
			factorsCurrCondition = factorsRelConditionSum / cells.length
			console.log 'factor condition sum', factorsConditionSum
			console.log 'factor condition cur', factorsCurrCondition
			console.log '-- cur ball size', @balls[node.nodeId].ball3d.geometry.radius
			console.log '-- new ball size', @opts.ballSize * factorsCurrCondition

			# Tween size
			ball = @balls[node.nodeId]
			@_tweenBallSize ball, ball.ball3d.geometry.radius, @opts.ballSize * factorsCurrCondition
			###

			allFactorsChangeSum = 0
			allFactorsChangeAvg = 0

			for cell in cells
				factor = @organism.getFactorOfType cell.factorType
				
				factorDishStart = factor.disharmonyHistory[0]
				factorDishCurr  = factor.disharmonyHistory[factor.disharmonyHistory.length - 1]
				allFactorsChangeSum += factorDishCurr / factorDishStart

				#console.log '··· factor dish start', factorDishStart
				#console.log '··· factor dish current', factorDishCurr
				#console.log '··· factor dish rel', factorDishCurr / factorDishStart

			allFactorsChangeAvg = allFactorsChangeSum / cells.length
			#console.log '::: node factors relative dish avg', allFactorsChangeAvg

			# Tween size
			ball = @balls[node.nodeId]
			newBallRelSize = Math.pow(allFactorsChangeAvg, 3.5)
			#newBallSize = @opts.ballSize * Math.pow(allFactorsChangeAvg, 10)
			#@_tweenBallSize ball, ball.ball3d.geometry.radius, 
			#ball.ball3d.geometry.radius = newBallSize
			ballScaleFrom = { 'x':ball.ball3d.scale.clone().x, 'y':ball.ball3d.scale.clone().y, 'z':ball.ball3d.scale.clone().z }
			ballScaleTo = { 'x':newBallRelSize, 'y':newBallRelSize, 'z':newBallRelSize }
			#ball.ball3d.scale.x = ball.ball3d.scale.y = ball.ball3d.scale.z = newBallRelSize # new THREE.Vector3 newBallRelSize, newBallRelSize, newBallRelSize
			@_tweenSomething ball.ball3d.scale, ballScaleFrom, ballScaleTo, 300

			#console.log '::: ball size current', ball.ball3d.geometry.radius
			#console.log '::: ball size new', newBallRelSize




	# Tweens a ball's position between two points
	_tweenBall: (ball, from, to) ->
		tween = new TWEEN.Tween( from ).to( to, 300 )
		tween.easing TWEEN.Easing.Quadratic.InOut
		tween.onUpdate () ->
			ball.ball3d.position.set @.x, @.y, @.z
		tween.start()

	_tweenBallSize: (ball, from, to) ->
		tween = new TWEEN.Tween( { 'size':from } ).to( { 'size':to }, 100 )
		tween.easing TWEEN.Easing.Quadratic.InOut
		tween.onUpdate () ->
			ball.ball3d.radius = @.size
		tween.start()


	# Tweens the camera's distance between two points
	_tweenCameraDistance: (to) ->
		_this = @

		tween = new TWEEN.Tween( { 'distance':@opts.cameraDistance } ).to( { 'distance':to }, 400 )
		tween.easing TWEEN.Easing.Quadratic.InOut
		tween.onUpdate () ->
			_this.opts.cameraDistance = @.distance
		tween.start()


	# Handles node comparison
	onCompareNodes: (compareData) ->
		for node in compareData.nodes
			ball = @balls[node.nodeId]
			@_animateComparingBall ball


	# Animates the color of an ball whose node is in comparison
	_animateComparingBall: (ball) ->
		@_tweenBallColor ball, @opts.ballColor, @opts.ballColorCompare, 200, () =>
			@_tweenBallColor ball, ball.ball3d.material.ambient, @opts.ballColor, 1000


	# Handles node influence
	onInfluenceNode: (influenceData) ->
		@_animateInfluencedBall @balls[influenceData.node.node.nodeId]


	# Animates properties of a ball being influenced
	_animateInfluencedBall: (ball) ->
		@_tweenBallColor ball, @opts.ballColor, @opts.ballColorInfluence, 200, () =>
			@_tweenBallColor ball, ball.ball3d.material.ambient, @opts.ballColor, 3000


	# Tweens a ball's color between two values
	_tweenBallColor: (ball, fromColor, toColor, duration, callback) ->
		colorFrom = { 'r':fromColor.r, 'g':fromColor.g, 'b':fromColor.b }
		colorTo   = { 'r':toColor.r,   'g':toColor.g,   'b':toColor.b   }

		# Tween color
		tween = new TWEEN.Tween( colorFrom ).to( colorTo, duration ).easing( TWEEN.Easing.Quadratic.InOut )
		tween.onUpdate () ->
			ball.ball3d.material.ambient.setRGB @.r, @.g, @.b

		# Add possible callback
		if callback
			tween.onComplete callback

		tween.start()


	# Tweens a color object between two values
	_tweenColor: (targetColor, fromColor, toColor, duration, callback) ->
		colorFrom = { 'r':fromColor.r, 'g':fromColor.g, 'b':fromColor.b }
		colorTo   = { 'r':toColor.r,   'g':toColor.g,   'b':toColor.b   }

		# Tween color
		tween = new TWEEN.Tween( colorFrom ).to( colorTo, duration ).easing( TWEEN.Easing.Quadratic.InOut )
		tween.onUpdate () ->
			targetColor.setRGB @.r, @.g, @.b

		# Add possible callback
		if callback
			tween.onComplete callback

		tween.start()


	# Generic tween function
	_tweenSomething: (something, from, to, duration, callback) ->
		#console.log '#_tweenSomething', something, from, to, duration

		# Create tween
		tween = new TWEEN.Tween( from ).to( to, duration ).easing( TWEEN.Easing.Quadratic.InOut )
		tween.onUpdate () ->
			for key in Object.keys(to)
				something[key] = to[key]

		# Add possible callback
		if callback
			tween.onComplete callback

		tween.start()



window.Audanism.Graphic.VisualOrganism = VisualOrganism
