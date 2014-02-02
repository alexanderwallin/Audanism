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

			'roomSize':            3000
			'roomVertices':        100
			'roomColor':           new THREE.Color(0x4A6D8A) #(0x3AAB92)
			'roomColor2':          new THREE.Color(0x3D6D7D)
			'roomColorChaos':      new THREE.Color(0x941950)

			'fogColorStart':       new THREE.Color(0x999999)

			'ballSize':            10
			'ballColor':           new THREE.Color(0xF2ED50)
			'ballColorCompare':    new THREE.Color(0xF24900) #new THREE.Color(0xED8A34)
			'ballCompareTime':     1000
			'ballColorInfluence':  new THREE.Color(0xED34A0)
			'ballInfluenceTime':   2000
			'ballColorVeteran':    new THREE.Color(0x1F36E0)
		}

		@state = {}

		@queue    = []
		@tweens   = []
		@cubes    = []
		@newCubes = []
		@newBalls = []

		# Resize handler
		$(window).on 'resize', @onWindowResize.bind(@)

		# Init handlers
		EventDispatcher.listen 'audanism/init/organism',  @, @onInitOrganism

		# Real-time handlers
		EventDispatcher.listen 'audanism/iteration',      @, @onIteration
		EventDispatcher.listen 'audanism/compare/nodes',  @, @onCompareNodes
		EventDispatcher.listen 'audanism/influence/node', @, @onInfluenceNode

		#$('html').addClass 'canvas-only'


	# Handles organism init
	onInitOrganism: (organism) ->
		#console.log '#onInitOrganism', organism, @
		@organism = organism

		@init()


	# Window resize handler
	onWindowResize: (e) ->
		@camera.aspect = window.innerWidth / window.innerHeight;
		@camera.updateProjectionMatrix();

		@renderer.setSize( window.innerWidth, window.innerHeight );


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
		#console.log '#buildScene'

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
		@camera = new THREE.PerspectiveCamera 50, window.innerWidth / window.innerHeight, 1, 20000
		@camera.position = new THREE.Vector3( 1, 0.25, 1 ).multiplyScalar( @opts.cameraDistanceStart )
		@camera.target = new THREE.Vector3 0, 0, 0
		@camera.lookAt @camera.target
		@camera.setLens 35

		@scene = new THREE.Scene()
		#@scene.fog = new THREE.Fog( 0x999999, @opts.clusterSize / 2, @opts.clusterSize * 12 )

		# Container sphere
		@room = new THREE.Mesh( new THREE.SphereGeometry(@opts.roomSize, @opts.roomVertices, @opts.roomVertices / 2), new THREE.MeshPhongMaterial({ 'ambient': @opts.roomColor.clone(), 'side': THREE.BackSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors }) )
		@scene.add @room

		### Skybox
		imagePrefix = "img/skybox2/"
		directions  = ["xpos", "xneg", "ypos", "yneg", "zpos", "zneg"]
		imageSuffix = ".jpg"
		skyGeometry = new THREE.CubeGeometry( @opts.roomSize, @opts.roomSize, @opts.roomSize );
		
		materialArray = []
		for i in [0..5]
			materialArray.push new THREE.MeshBasicMaterial {
				map: THREE.ImageUtils.loadTexture( imagePrefix + directions[i] + imageSuffix )
				side: THREE.BackSide
			}
		skyMaterial = new THREE.MeshFaceMaterial( materialArray )
		@room = new THREE.Mesh( skyGeometry, skyMaterial )
		@scene.add( @room )
		###

		# Make balls
		for i in [0..@numBalls-1]

			# Make ball info object
			ball = {
				ballId:     i
				hello:      "hello. i am ball no #{ i }."
				direction:  new THREE.Vector3 (2 * Math.random() - 1), (2 * Math.random() - 1), (2 * Math.random() - 1)
				ballSize:   @opts.ballSize
				hoverPhase: Math.random() * Math.PI * 2
				hoverSpeed: 1 / (50 + Math.random() * 100)
				state:      {
					numInfluenced: 0
					hover: true
				}
				ref:        {
					numInfluenced: 0
				}
			}

			# Set ball position from direction
			ball.pos = new THREE.Vector3 (ball.direction.x * Math.random() * @opts.clusterSize), (ball.direction.y * Math.random() * @opts.clusterSize), (ball.direction.z * Math.random() * @opts.clusterSize)
			ball.currPos = ball.pos.clone()

			# Stuff that should be changed in animate()
			ball.changes = {}

			# Make ball 3d object
			ballGeometry  = new THREE.SphereGeometry ball.ballSize, 20, 10
			ballMaterials = [
				new THREE.MeshLambertMaterial({ 'ambient':@opts.ballColor.clone(), 'side': THREE.DoubleSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors })
				new THREE.MeshPhongMaterial({ 'color':0xffffff, 'specular':0xffaaaa })
			]
			#ball3d        = new THREE.SceneUtils.createMultiMaterialObject ballGeometry, ballMaterials 
			ball3d        = new THREE.Mesh ballGeometry, ballMaterials[0]
			ball3d.ballId = ball.ballId; # Store id reference

			# Store ball 3d object in ball info object
			ball.ball3d   = ball3d

			# Position ball
			ball.ball3d.position = ball.pos.clone()

			#console.log ball.pos
			@scene.add ball.ball3d
			@balls[i] = ball

			###
			# Ball glow
			ballGlowMaterial = new THREE.SpriteMaterial { 
				map: new THREE.ImageUtils.loadTexture( 'img/glow.png' )
				useScreenCoordinates: false
				#alignment: THREE.SpriteAlignment.center
				color: 0x111111 # @opts.ballColor.clone().multiplyScalar(0.1)
				transparent: false
				blending: THREE.AdditiveBlending
			}
			ballGlowSprite = new THREE.Sprite( ballGlowMaterial )
			ballGlowSprite.scale.set(50, 50, 1.0)
			ball.ball3d.add(ballGlowSprite) # this centers the glow at the mesh
			###

		#console.log @balls

		# Create a plane
		#planeXZ = new THREE.Mesh( new THREE.PlaneGeometry @opts.clusterSize * 3, @opts.clusterSize * 3, new THREE.MeshLambertMaterial { 'color':0x22eecc, 'side': THREE.DoubleSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors } )
		#planeXZ.position.set 0, 0, 0
		#@scene.add planeXZ

		# Add mother point star of death
		@centerBall = new THREE.Mesh new THREE.TetrahedronGeometry( 10, 0 ), new THREE.MeshLambertMaterial( { 'ambient':0x331177, 'opacity':0.1, 'side':THREE.DoubleSide } )
		ballGlowMaterial = new THREE.SpriteMaterial { 
			map: new THREE.ImageUtils.loadTexture( 'img/glow.png' )
			useScreenCoordinates: false
			#alignment: THREE.SpriteAlignment.center
			color: 0x222222 # @opts.ballColor.clone().multiplyScalar(0.1)
			transparent: false
			blending: THREE.AdditiveBlending
		}
		ballGlowSprite = new THREE.Sprite( ballGlowMaterial )
		ballGlowSprite.scale.set(50, 50, 1.0)
		@centerBall.add(ballGlowSprite)
		@scene.add @centerBall

		# Add lights
		@lightAmb = new THREE.AmbientLight 0xffffff
		@scene.add @lightAmb

		@lightSpot = new THREE.DirectionalLight 0xffffff, 0.2
		@lightSpot.position.set 0, 1, 1
		@scene.add @lightSpot

		# Add axises
		#@axis = new THREE.AxisHelper( 500 )
		#@scene.add @axis

		# Renderer
		@renderer = new THREE.WebGLRenderer { 'alpha':false, 'antialias':true }
		#renderer.setClearColor( 0x000000, 0 )
		@renderer.setSize window.innerWidth, window.innerHeight


		# Orbin control
		#@orbitControls = new THREE.OrbitControls @camera, @renderer.domElement

		#console.log @scene

		$('#container').append @renderer.domElement


	# Animate
	animate: () ->

		requestAnimationFrame( Audanism.Graphic.public.animate )

		@frame++

		# Rotate camera around cluster
		@camera.position.x = Math.sin( @frame / 100 ) * @opts.cameraDistance
		@camera.position.z = Math.cos( @frame / 100 ) * @opts.cameraDistance 
		@camera.lookAt( @camera.target )

		# Hovering balls
		for ball in @balls
			if ball.state.hover
				ball.ball3d.position.y = ball.currPos.y + Math.sin( ball.hoverPhase + @frame * ball.hoverSpeed ) * 15


		# Update cubes
		if @instaCubes?
			@_updateInstaCubes()

		# Add possible new cubes
		if @newCubes.length > 0
			for cube in @newCubes

				# Add cube to scene
				@cubes.push cube
				@scene.add cube

				# Add line to mothership
				lineGeometry = new THREE.Geometry()
				lineGeometry.vertices.push new THREE.Vector3 0, 0, 0
				lineGeometry.vertices.push cube.position.clone()
				lineMaterial = new THREE.LineBasicMaterial { 'color':0xE3105A, 'opacity':0.3 }
				@scene.add new THREE.Line lineGeometry, lineMaterial

			@newCubes = []

		# Room color
		colorDiff = 1 - @state.latestDisharmonyChange
		#rgbString = "rgb(100, #{Math.round(100 + (Math.cos( @frame / 200 ) * 20))}, #{Math.round(80 + (Math.sin( @frame / 200 ) * 20))})"

		roomColor = @opts.roomColor.clone()
		roomColor.lerp(@opts.roomColor2.clone(), 0.5 + Math.sin(@frame / 20) / 2)

		#roomColor = new THREE.Color rgbString
		relRoomColor = roomColor.clone()
			
		if colorDiff <= 0
			relRoomColor.lerp(new THREE.Color(0x000000), Math.abs(colorDiff))
		else
			relRoomColor.lerp(new THREE.Color(0xffffff), Math.abs(colorDiff))

		#@room.material.ambient = relRoomColor

		TWEEN.update()

		#@orbitControls.update()

		# Render
		@renderer.render( @scene, @camera )


	addToQueue: (fn, args) ->
		@queue.push { 'fn':fn, 'args':args }

	runQueue: () ->
		for action in @queue
			action.fn.call @, action.args


	# Handles an organism iteration
	onIteration: (influenceInfo) ->
		#console.log '#onIteration'

		organism = influenceInfo.organism

		disharmony = organism.getDisharmonyHistoryData()
		if disharmony.length == 0
			return

		disharmony = disharmony[disharmony.length - 1]

		if not @opts.initialDisharmonyData?
			@opts.initialDisharmonyData = disharmony
			#console.log 'stored initial disharmony', disharmony

		relativeDisharmony = disharmony[2] / @opts.initialDisharmonyData[2]

		@largestDistance = 0


		# Set balls distance from center depending on the organism's state
		for ball in @balls

			# Tween the ball
			newPos = ball.pos.clone().multiplyScalar relativeDisharmony
			tweenFrom = ball.ball3d.position.clone()
			tweenTo   = { 'x':newPos.x, 'y':newPos.y, 'z':newPos.z } # newPos.clone()

			#@_tweenBall ball, tweenFrom, tweenTo

			# Store furthest position if this is that
			if (ball.ball3d.position.length() > @largestDistance)
				@largestDistance = ball.ball3d.position.length()

		# Move camera according to the ball furthest out
		console.log 'tween camera to', @largestDistance * (@opts.cameraDistanceStart / @opts.clusterSize)
		#@addToQueue @_tweenCameraDistance, [@largestDistance * (@opts.cameraDistanceStart / @opts.clusterSize)]
		@_tweenCameraDistance @largestDistance * (@opts.cameraDistanceStart / @opts.clusterSize)

		# Tween fog
		latestDisharmonyBlock = organism.getDisharmonyHistoryData().slice(-10)

		disharmonySum = 0
		(disharmonySum += dish[2] for dish in latestDisharmonyBlock)
		disharmonyAvg = disharmonySum / latestDisharmonyBlock.length

		#latestDisharmonyChange = latestDisharmonyBlock[latestDisharmonyBlock.length - 1][2] / latestDisharmonyBlock[0][2]
		latestDisharmonyChange = latestDisharmonyBlock[latestDisharmonyBlock.length - 1][2] / disharmonyAvg
		@state.latestDisharmonyChange = latestDisharmonyChange

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
		#	console.log 'latest disharmony change', latestDisharmonyChange
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
			newBallRelSize = Math.pow(allFactorsChangeAvg, 2)
			#console.log 'current ball scale', ball.ball3d.scale
			ballScaleFrom = { 'x':ball.ball3d.scale.clone().x, 'y':ball.ball3d.scale.clone().y, 'z':ball.ball3d.scale.clone().z }
			ballScaleTo = { 'x':newBallRelSize, 'y':newBallRelSize, 'z':newBallRelSize }
			ball.ball3d.scale.x = ball.ball3d.scale.y = ball.ball3d.scale.z = newBallRelSize # new THREE.Vector3 newBallRelSize, newBallRelSize, newBallRelSize

			###
			_tweenBack = () =>
				origScale = { 'x':1/ballScaleTo.x, 'y':1/ballScaleTo.y, 'z':1/ballScaleTo.z }
				console.log ball.ballId
				if ball.ballId is 1
					console.log 'original scale', origScale
				@_tweenSomething ball.ball3d.scale, ballScaleTo, origScale, 4000

			@_tweenSomething ball.ball3d.scale, ballScaleFrom, ballScaleTo, 50, _tweenBack
			###

			#if ball.ballId is 0
			#	console.log '     ... ball scale from', ball.ball3d.scale, 'to', ballScaleTo

			#@addToQueue ball.ball3d.scale, [new THREE.Vector3( newBallRelSize, newBallRelSize, newBallRelSize )]
			#ball.ball3d.scale = new THREE.Vector3( newBallRelSize, newBallRelSize, newBallRelSize )
			#ball.ball3d.children[ball.ball3d.children.length - 1].scale = ball.ball3d.scale.clone().multiplyScalar(50)

			#@_tweenBallSize ball, ballScaleFrom, ballScaleTo, 100, () ->
			
			#	@_tweenBallSize ball, ball.ball3d.scale, ballScaleFrom, 1000


			#console.log '::: ball size current', ball.ball3d.geometry.radius
			#console.log '::: ball size new', newBallRelSize




	# Handles node comparison
	onCompareNodes: (compareData) ->
		for node in compareData.nodes
			@_animateComparingBall @balls[node.nodeId]


	# Animates the color of an ball whose node is in comparison
	_animateComparingBall: (ball) ->
		#console.log '#_animateComparingBall', ball

		# Ball color
		target = ball.ball3d.material.ambient
		ballColor = target.clone() # { 'r':@opts.ballColor.r, 'g':@opts.ballColor.g, 'b':@opts.ballColor.b }
		ballColorCompare = { 'r':@opts.ballColorCompare.r, 'g':@opts.ballColorCompare.g, 'b':@opts.ballColorCompare.b }

		@_tweenBallColor ball, ballColor.clone(), @opts.ballColorCompare.clone(), 200, () =>
			@_tweenBallColor ball, @opts.ballColorCompare.clone(), ballColor.clone(), 500

		# Ball position
		ball.state.hover = false
		newPos = { 
			'x': ball.ball3d.position.x + (Math.random() * 2 - 1) * 15
			'y': ball.ball3d.position.y + (Math.random() * 2 - 1) * 15
			'z': ball.ball3d.position.z + (Math.random() * 2 - 1) * 15
		}
		@_tweenSomething ball.ball3d.position, ball.ball3d.position.clone(), newPos, 30, () =>
			ball.currPos = ball.ball3d.position.clone()
			ball.state.hover = true
		#ball.ball3d.position.set newPos.x, newPos.y, newPos.z


	# Handles node influence
	onInfluenceNode: (influenceData) ->
		@_animateInfluencedBall @balls[influenceData.node.node.nodeId]

		if influenceData.meta.current is 1 and influenceData.meta.source? and influenceData.meta.source is 'instagram'
			@_spawnInstaCube.bind @

			setTimeout () =>
				@_spawnInstaCube(influenceData)
			, 500


	# Animates properties of a ball being influenced
	_animateInfluencedBall: (ball) ->
		console.log '#_animateInfluencedBall', ball

		console.log '   new state', ball.state

		# Ball color
		target = ball.ball3d.material.ambient
		ballColor = target.clone() # { 'r':@opts.ballColor.r, 'g':@opts.ballColor.g, 'b':@opts.ballColor.b }
		ballColorInfluence = { 'r':@opts.ballColorInfluence.r, 'g':@opts.ballColorInfluence.g, 'b':@opts.ballColorInfluence.b }

		@_tweenBallColor ball, ballColor.clone(), @opts.ballColorInfluence.clone(), 200, () =>
			@_tweenBallColor ball, @opts.ballColorInfluence.clone(), ballColor.clone(), 2000, () =>
				ball.state.numInfluenced += 1

				routine = ball.state.numInfluenced / 5
				routine = 1 if routine > 1

				console.log 'influenced ball finished tweeing', ball
				ball.currPos = ball.ball3d.position.clone()
				ball.state.hover = true

				nextColor = ball.ball3d.material.ambient.clone()
				nextColor.lerp( @opts.ballColorVeteran.clone(), routine )

				@_tweenBallColor ball, ball.ball3d.material.ambient.clone(), { 'r':nextColor.r, 'g':nextColor.g, 'b':nextColor.b }, 10

		# Ball position
		ball.state.hover = false
		newPos = { 
			'x': ball.ball3d.position.x + (Math.random() * 2 - 1) * 300
			'y': ball.ball3d.position.y + (Math.random() * 2 - 1) * 300
			'z': ball.ball3d.position.z + (Math.random() * 2 - 1) * 300
		}
		@_tweenSomething ball.ball3d.position, ball.ball3d.position.clone(), newPos, 900
		#ball.ball3d.position.set newPos.x, newPos.y, newPos.z


	_spawnInstaCube: (influenceData) ->
		#console.log '#_spawnInstaCube', influenceData
		#igTexture = new THREE.ImageUtils.loadTexture influenceData.meta.sourceData.images.thumbnail.url

		#cubeCam = new THREE.CubeCamera 0.1, 500, 128
		#@scene.add cubeCam

		cubeGeometry = new THREE.CubeGeometry 30, 30, 30
		cubeMaterials = [
			new THREE.MeshLambertMaterial { 'ambient':0x0E1B21, 'side':THREE.DoubleSide }
			#new THREE.MeshBasicMaterial { 'envMap':cubeCam.renderTarget, 'blending':THREE.NormalBlending }
			#new THREE.MeshPhongMaterial { 'diffuse':0x999999, 'specular':0xffffff, 'side':THREE.DoubleSide }
		]
		###
		cubeMaterials [
			new THREE.MeshLambertMaterial { 'ambient':0x07325E, 'side':THREE.DoubleSide }
			new THREE.MeshPhongMaterial { 'ambient':0x07325E, 'side':THREE.DoubleSide }
		]
		###
		cube = new THREE.Mesh cubeGeometry, cubeMaterials[0]
		#cube = new THREE.SceneUtils.createMultiMaterialObject cubeGeometry, cubeMaterials

		cube.position.set (1 - 2 * Math.random()) * @opts.clusterSize * 0.5 * (1.5 - Math.random()), (1 - 2 * Math.random()) * @opts.clusterSize * (1.5 - Math.random()), (1 - 2 * Math.random()) * @opts.clusterSize * (1.5 - Math.random()) # @opts.clusterSize + (200 - Math.random() * 100), @opts.clusterSize + (200 - Math.random() * 100), @opts.clusterSize + (200 - Math.random() * 100)
		cube.rotation.set Math.random(), Math.random(), Math.random()

		#cubeCam.position = cube.position

		if not @instaCubes?
			@instaCubes = []

		@instaCubes.push { 
			'cube':cube
			#'cubeCam':cubeCam
			'posStart':cube.position.clone()
			'phase':Math.random() * Math.PI * 2
			'hoverSpeed': 1 / (0.01 + Math.random() * 80)
			'rotateSpeed': 1 / (10 + Math.random() * 40)
		}
		@newCubes.push cube


	_updateInstaCubes: () ->

		for cubeInfo in @instaCubes
			#cubeInfo.cube.visible = false
			#cubeInfo.cubeCam.rotation = @camera.rotation #.set -@camera.rotation.x, -@camera.rotation.y, -@camera.rotation.z
			#cubeInfo.cubeCam.updateCubeMap @renderer, @scene
			#cubeInfo.cube.visible = true
		
			# Hover in y
			#cubeInfo.cube.position.y = cubeInfo.posStart.y + Math.sin( cubeInfo.phase + @frame / 50 ) * 20

			# Rotate slowly
			cubeInfo.cube.rotation.x += cubeInfo.rotateSpeed



	# Tweens a ball's position between two points
	_tweenBall: (ball, from, to, duration) ->
		duration = duration || 300
		tween = new TWEEN.Tween( from ).to( to, duration )
		@tweens.push tween
		tween.easing TWEEN.Easing.Quadratic.InOut
		tween.onUpdate () ->
			ball.ball3d.position.set @.x, @.y, @.z
		tween.start()

	_tweenBallSize: (ball, from, to, duration, callback) ->

		tween = new TWEEN.Tween( { from } ).to( to, duration )
		@tweens.push tween
		tween.easing TWEEN.Easing.Linear.None
		tween.onUpdate () ->
			ball.ball3d.scale.set @.x, @.y, @.z
		tween.start()


	# Tweens the camera's distance between two points
	_tweenCameraDistance: (to) ->
		_this = @

		tween = new TWEEN.Tween( { 'distance':@opts.cameraDistance } ).to( { 'distance':to }, 400 )
		@tweens.push tween
		tween.easing TWEEN.Easing.Quadratic.InOut
		tween.onUpdate () ->
			_this.opts.cameraDistance = @.distance
		tween.start()


	# Tweens a ball's color between two values
	_tweenBallColor: (ball, fromColor, toColor, duration, callback) ->
		colorFrom = { 'r':fromColor.r, 'g':fromColor.g, 'b':fromColor.b }
		colorTo   = { 'r':toColor.r,   'g':toColor.g,   'b':toColor.b   }

		# Tween color
		tween = new TWEEN.Tween( colorFrom ).to( colorTo, duration ).easing( TWEEN.Easing.Quadratic.InOut )
		@tweens.push tween
		tween.onUpdate () ->
			if ball.ball3d.children.length > 0
				ball.ball3d.children[0].material.ambient.setRGB @.r, @.g, @.b
			else
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
		@tweens.push tween
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
		@tweens.push tween
		tween.onUpdate () ->
			#console.log '       tween update ::', to
			for key in Object.keys(to)
				something[key] = to[key]

		# Add possible callback
		if callback
			tween.onComplete callback

		tween.start()

	



window.Audanism.Graphic.VisualOrganism = VisualOrganism
