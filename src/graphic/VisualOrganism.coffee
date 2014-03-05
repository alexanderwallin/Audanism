###
	WebGL organism visualizer
###
class VisualOrganism


	# Constructor
	constructor: () ->
		_this = @

		# Options
		@opts = {
			'cameraDistanceStart': 1600
			'cameraDistance':      1300
			'clusterSize':         1000

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

			'groupCubesEvery':     3
			'cubesPerGroup':       2
		}

		@state = {}

		@queue        = []
		@tweens       = []
		@cubes        = []
		@newCubes     = []
		@cubeLines    = []
		@megaCubes    = []
		@cubesGrouped = 0
		
		@newBalls     = []

		# Resize handler
		$(window).on 'resize', @onWindowResize.bind(@)

		# Init handlers
		EventDispatcher.listen 'audanism/init/organism',  @, @onInitOrganism

		# Real-time handlers
		EventDispatcher.listen 'audanism/iteration',              @, @onIteration
		EventDispatcher.listen 'audanism/compare/nodes',          @, @onCompareNodes
		EventDispatcher.listen 'audanism/influence/node',         @, @onInfluenceNode
		EventDispatcher.listen 'audanism/influence/factor/after', @, @onInfluenceFactorAfter
		EventDispatcher.listen 'audanism/node/add',               @, (info) =>
			@createBalls info.numNodes

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

		now = new Date()

		# Performance
		@lastLoop    = 0
		@thisLoop    = 0
		@fps         = 0
		@numBadFps   = 0

		# Scene
		@camera
		@scene
		@renderer
		@stats
		
		# Lights
		@lightAmb
		@lightSpot

		# Factors
		@factors     = []
		
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


		# --- Start buildin' --- #


		# Renderer
		@renderer = new THREE.WebGLRenderer { 'alpha':false, 'antialias':true }
		@renderer.setSize window.innerWidth, window.innerHeight
		@renderer.clearColor = 0xff1190

		# Scene
		@scene = new THREE.Scene()
		#@scene.fog = new THREE.Fog( 0x999999, @opts.clusterSize / 2, @opts.clusterSize * 12 )

		# Camera
		@camera = new THREE.PerspectiveCamera 50, window.innerWidth / window.innerHeight, 1, 20000
		@camera.position = new THREE.Vector3( 1, 0.25, 1 ).multiplyScalar( @opts.cameraDistanceStart )
		@camera.target = new THREE.Vector3 0, 0, 0
		@camera.lookAt @camera.target
		@camera.setLens 35

		# Stats
		@stats = new Stats()
		$(@stats.domElement).attr('id', 'fps-stats');
		container.appendChild( @stats.domElement );

		# Add lights
		@lightAmb = new THREE.AmbientLight 0xffffff
		@scene.add @lightAmb

		@lightSpot = new THREE.DirectionalLight 0xaaffff, 0.2
		@lightSpot.position.set 0, 1, 1
		@scene.add @lightSpot

		@lightSpot2 = new THREE.DirectionalLight 0xffffaa, 0.2
		@lightSpot2.position.set 0.3, 1, -1
		@scene.add @lightSpot2

		# Add axises
		#@axis = new THREE.AxisHelper( 500 )
		#@scene.add @axis

		# Container sphere
		roomColor = @opts.roomColor.clone()
		@room = new THREE.Mesh( new THREE.SphereGeometry(@opts.roomSize, @opts.roomVertices, @opts.roomVertices / 2), new THREE.MeshPhongMaterial({ 'ambient': roomColor, 'side': THREE.BackSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors }) )
		@setDaylight()
		@scene.add @room

		# Update daylight once per minute
		setInterval () =>
			@state.shouldSetDaylight = true
		, 60000

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

		# Add mother point
		@centerBall = new THREE.Mesh new THREE.TetrahedronGeometry( 10, 0 ), new THREE.MeshLambertMaterial( { 'ambient':0x331177, 'side':THREE.DoubleSide } )
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

		# Make factor cones
		for factor in @organism.getFactors()

			factorColor = new THREE.Color()
			factorColor.setHSL( factor.factorType / @organism.getFactors().length, 0.6, 0.7 )

			factor3d = new THREE.Mesh(
				new THREE.CylinderGeometry( 50, 0, factor.factorValue * 3 )
				new THREE.MeshLambertMaterial({ 'ambient':factorColor, 'side':THREE.FrontSide } )
			)
			factor3d.position.set(
				if randomInt(0, 1) is 1 then randomInt(-800, -600) else randomInt(600, 800)
				0
				if randomInt(0, 1) is 1 then randomInt(-800, -600) else randomInt(600, 800)
			)

			factor3d.userData = {
				'isModifying':     false
				'startPosition':   factor3d.position.clone()
				'hover':           true
				'hoverStartFrame': 0
				'initialValue':    factor.factorValue
				'baseColor':       factor3d.material.ambient.clone()
			}
			factor3d.dynamic = true

			@factors[factor.factorType] = factor3d
			@scene.add factor3d

		# Make balls
		@createBalls @numBalls

		#console.log @balls

		# Orbin control
		@orbitControls = new THREE.OrbitControls @camera, @renderer.domElement
		@orbitControls.autoRotate = true
		@orbitControls.autoRotateSpeed = -1

		$('#container').append @renderer.domElement


	# Animate
	animate: () ->

		requestAnimationFrame( Audanism.Graphic.public.animate )

		# FPS
		@thisLoop = new Date()
		if @lastLoop > 0
			@fps = 1000 / (@thisLoop - @lastLoop)
		else
			@fps = 60
		@lastLoop = @thisLoop

		if @fps < 20
			#console.log( 'BAD FPS!!!', @fps )
			@numBadFps++
			EventDispatcher.trigger( 'audanism/performance/badfps', @fps )
		else
			@numBadFps = 0
			EventDispatcher.trigger( 'audanism/performance/goodfps', @fps )

		if @numBadFps >= 5
			console.log( '!!!!!!!!!!!!!!!!!! KILL EVERYTHING !!!!!!!!!!!!!!!!!!!!' )
			EventDispatcher.trigger( 'audanism/performance/bad', @fps )

		# Increment frame
		@frame++
		EventDispatcher.trigger( 'audanism/graphic/update', @frame )

		# Daylight
		if @state.shouldSetDaylight
			@setDaylight()
			@state.shouldSetDaylight = false

		# Factors
		_moveFactor = (factorType) =>
			factor   = @organism.getFactorOfType factorType
			factor3d = @factors[factorType]
			
			factor3d.userData.hover       = false
			factor3d.userData.isModifying = true

			@_tweenSomething factor3d.position, { 'y':factor3d.position.y }, { 'y':(1000 - factor.disharmony) / 2 }, 1000, () =>
				factor3d.userData.startPosition = factor3d.position.clone()
				factor3d.userData.hover         = true
				factor3d.userData.isModifying   = false

				#console.log '--> done (' + factor.factorValue + '). now:', factor3d.position.y

		for factor in @organism.getFactors()
			factor3d = @factors[factor.factorType]

			# Factor hovering
			if not factor3d.userData.isModifying and @frame > 10
				#console.log '--> move factor', factor.factorType, 'from', factor3d.position.y, 'to', 1000 - factor.disharmony 
				_moveFactor factor.factorType
			else if factor3d.userData.hover
				factor3d.position.y = factor3d.userData.startPosition.y + 200 * Math.sin( (@frame - factor3d.userData.hoverStartFrame) / (10 * factor.factorValue) )
			

		# Hovering balls
		for ball in @balls
			if ball.ball3d.userData.hover
				ball.ball3d.position.y = ball.ball3d.userData.startPosition.y + Math.sin( ball.hoverPhase + (@frame - ball.ball3d.userData.hoverStartFrame) * ball.hoverSpeed ) * 15

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
				line = new THREE.Line lineGeometry, lineMaterial
				@scene.add line

				cube.userData.cubeLine = line

			@newCubes = []

		# Rotate mega cubes
		for megaCube in @megaCubes
			megaCube.rotation.x += 0.003
			megaCube.rotation.z += 0.0007

		# Offset room color hue
		if @frame % 10 is 1
			@room.material.ambient.offsetHSL 0.0001, 0, 0

		# Update external stuff
		TWEEN.update()
		@stats.update()
		@orbitControls.update()

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

		# Get disharmony data
		disharmony = organism.getDisharmonyHistoryData()
		if disharmony.length == 0
			return

		# Just get the latest
		disharmony = disharmony[disharmony.length - 1]

		# Store initial data if not set
		if not @opts.initialDisharmonyData?
			@opts.initialDisharmonyData = disharmony

		# Calculate disharmony relatively the initial disharmony
		relativeDisharmony = organism.getDisharmonyChange(10, 'actual') # disharmony[2] / @opts.initialDisharmonyData[2]

		# Float keeping track how far away the furthers away ball is
		@largestDistance = 0

		# Set balls distance from center depending on the organism's state
		for ball in @balls

			if @frame % 4 is 0
				# Tween the ball
				newPos = ball.pos.clone() # ball.ball3d.position.clone()
				newPos.multiplyScalar relativeDisharmony
				tweenFrom = ball.ball3d.position.clone()
				tweenTo   = { 'x':newPos.x, 'y':newPos.y, 'z':newPos.z } # newPos.clone()

				#@_tweenBall ball, tweenFrom, tweenTo
				ball.ball3d.userData.hover = false
				@_tweenSomething ball.ball3d.position, tweenFrom, tweenTo, 100, () =>
					ball.ball3d.userData.hover = true

			# Store furthest position if this is that
			if (ball.ball3d.position.length() > @largestDistance)
				@largestDistance = ball.ball3d.position.length()

		# Move camera according to the ball furthest out
		@_tweenCameraDistance @largestDistance * (@opts.cameraDistanceStart / @opts.clusterSize)

		# Change room color
		#	#console.log 'latest disharmony change', latestDisharmonyChange
		#@_tweenColor @room.material.ambient, @opts.roomColor, @opts.roomColor.clone().lerp( @opts.roomColorChaos, 1 - Math.pow(latestDisharmonyChange, 2) ), 100


		# Change ball size depending on factor disharmonies
		for node in @organism.getNodes()
			cells = node.getCells()
			ball = @balls[node.nodeId]

			# This is not for newly born nodes
			if @frame - ball.ball3d.userData.bornAt > 30

				# Get the average disharmony change of the node's cells' factors
				factorChangeSum = 0
				for cell in cells
					factorChangeSum += organism.getDisharmonyChangeForFactor cell.factorType, 20
				factorChangeAvg = factorChangeSum / cells.length
				#console.log 'factorChangeAvg', factorChangeAvg

				# Tween size
				newBallScale = Math.min(Math.pow(factorChangeAvg, 2), 10)
				#ballScaleFrom = { 'x':ball.ball3d.scale.clone().x, 'y':ball.ball3d.scale.clone().y, 'z':ball.ball3d.scale.clone().z }
				ballScaleTo = { 'x':newBallScale, 'y':newBallScale, 'z':newBallScale }
				@_tweenSomething ball.ball3d.scale, ball.ball3d.scale.clone(), ballScaleTo, 200


	# Darkens the room depending on the time of day
	setDaylight: () ->
		console.log ' -------------- #setDaylight() ----------------'
		now = new Date()

		roomColor = @opts.roomColor.clone()
		minutesOfDay = now.getHours() + now.getMinutes()
		minutesFromDark = if now.getHours() > 12 then 1440 - minutesOfDay else minutesOfDay
		darken = 0.4 * (720 - minutesFromDark) / 720
		roomColor.offsetHSL( 0, 0, -darken )

		@room.material.ambient = roomColor


	# Creates balls
	createBalls: (numBalls) ->
		console.log('VisualOrganism #createBalls', numBalls)
		for i in [0..numBalls-1]

			# Make ball info object
			ball = {
				ballId:     @balls.length
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

			# Position ball
			ball3d.position                 = ball.pos.clone()
			ball3d.userData.hover           = true
			ball3d.userData.startPosition   = ball3d.position.clone()
			ball3d.userData.hoverStartFrame = 0
			ball3d.userData.bornAt          = @frame

			# Add ball to scene
			ball3d.scale.set 0, 0 ,0
			@scene.add ball3d
			@_tweenSomething ball3d.scale, { 'x':0, 'y':0, 'z':0 }, { 'x':1, 'y':1, 'z':1 }, 1000
			
			@balls[ball.ballId] = ball

			# Store ball 3d object in ball info object
			ball.ball3d   = ball3d


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

		if not influenceData.node.node
			return

		@_animateInfluencedBall @balls[influenceData.node.node.nodeId]

		if influenceData.meta.current is 1 and influenceData.meta.source? and influenceData.meta.source is 'instagram'
			@_spawnInstaCube.bind @

			setTimeout () =>
				@_spawnInstaCube(influenceData)
			, 500


	# Handles factor influence
	onInfluenceFactorAfter: (influenceData) ->
		console.log('#onInfluenceFactorAfter', influenceData)

		# Get factor
		factor = influenceData.factor.factor
		factor3d = @factors[factor.factorType]
		
		factor3d.userData.hover = false
		factor3d.userData.isModifying = true

		# When completed, add scars
		_afterFactorAnimation = () =>

			# Get existing toruses
			if not factor3d.userData.toruses
				factor3d.userData.toruses = []
			existingToruses = factor3d.userData.toruses

			# Some settings
			torusMargin = 20
			torusSize   = 10

			# Color and size
			if existingToruses.length > 0
				lastTorus = existingToruses[existingToruses.length - 1]

				torusColor  = lastTorus.material.ambient.clone()
				torusRadius = lastTorus.geometry.radius
				torusSize   = lastTorus.geometry.tube
			else
				torusColor  = factor3d.material.ambient.clone()
				torusRadius = factor3d.geometry.radiusTop
				torusSize   = torusSize
			
			torusColor.offsetHSL( 0.05, -0.1, 0 )
			torusRadius *= 0.96
			torusSize   *= 0.9

			# Create torus
			torus = new THREE.Mesh(
				new THREE.TorusGeometry( torusRadius, torusSize )
				new THREE.MeshLambertMaterial({ 'ambient':torusColor, 'side':THREE.FrontSide })
			)
			torus.position.y = (factor3d.geometry.height / 2) + (torusMargin + existingToruses.length * (torusMargin + torusSize))
			torus.rotation.x = Math.PI / 2
			torus.scale.set 0, 0, 0

			# Add and scale up torus
			factor3d.userData.toruses.push torus
			factor3d.add torus
			@_tweenSomething torus.scale, { 'x':0, 'y':0, 'z':0 }, { 'x':1, 'y':1, 'z':1 }, 1000

			# Done.
			factor3d.userData.isModifying

		# Factor size
		factor3d.scale.y = factor.factorValue / factor3d.userData.initialValue

		# For wind: rotate according to the modified value
		console.log 'influence source attr', influenceData.meta.sourceAttr, influenceData.factor.value
		if influenceData.meta.sourceAttr is 'wind'
			@_tweenSomething factor3d.rotation, { 'z':factor3d.rotation.z }, { 'z':influenceData.factor.value }, 300, _afterFactorAnimation

		# For temperatur, change the hue
		else if influenceData.meta.sourceAttr is 'temperature'
			newColor = factor3d.userData.baseColor.clone()
			newColor.offsetHSL( 0, influenceData.factor.value / 5, 0 )
			@_tweenSomething factor3d.material.ambient, factor3d.material.ambient.clone(), newColor, 300, _afterFactorAnimation

		# Change position
		@_tweenSomething factor3d.position, factor3d.position.clone(), { 'x':(if randomInt(0, 1) is 1 then -100 else 100), 'y':(1000 - factor.disharmony) / 2 }, 300, () =>
			factor3d.userData.startPosition = factor3d.position.clone()
			factor3d.userData.hoverStartFrame = @frame
			factor3d.userData.hover = true


	# Animates properties of a ball being influenced
	_animateInfluencedBall: (ball) ->
		#console.log '#_animateInfluencedBall', ball

		#console.log '   new state', ball.state

		# Ball color
		target = ball.ball3d.material.ambient
		ballColor = target.clone() # { 'r':@opts.ballColor.r, 'g':@opts.ballColor.g, 'b':@opts.ballColor.b }
		ballColorInfluence = { 'r':@opts.ballColorInfluence.r, 'g':@opts.ballColorInfluence.g, 'b':@opts.ballColorInfluence.b }

		#@_tweenBallColor ball, ballColor.clone(), @opts.ballColorInfluence.clone(), 200, () =>
		#	@_tweenBallColor ball, @opts.ballColorInfluence.clone(), ballColor.clone(), 1000, () =>
		@_tweenSomething target, target.clone(), @opts.ballColorInfluence.clone(), 200, () =>
			@_tweenSomething target, @opts.ballColorInfluence.clone(), target.clone(), 200, () =>
				ball.state.numInfluenced += 1

				# Balls get bluer the more they are affected
				routine = ((ball.state.numInfluenced % 5)) / 5
				#console.log('ball routine', routine)

				#console.log 'influenced ball finished tweeing', ball
				ball.currPos = ball.ball3d.position.clone()
				ball.state.hover = true

				# Calculate color
				nextColor = @opts.ballColor.clone()
				nextColor.lerp( @opts.ballColorVeteran.clone(), routine )

				# Assign color
				#@_tweenBallColor ball, ball.ball3d.material.ambient.clone(), { 'r':nextColor.r, 'g':nextColor.g, 'b':nextColor.b }, 10
				@_tweenSomething ball.ball3d.material.ambient, ball.ball3d.material.ambient.clone(), { 'r':nextColor.r, 'g':nextColor.g, 'b':nextColor.b }, 10

				# For each time the ball reaches a routine of 1 it gets a ring
				if routine is 0
					ringRadius = 3 * ball.ball3d.geometry.radius
					ring = new THREE.Mesh(
						new THREE.CylinderGeometry( ringRadius, ringRadius, 1 )
						new THREE.MeshLambertMaterial({ 'ambient':ball.ball3d.material.ambient.clone(), 'transparent':true, 'opacity':0.3, 'side':THREE.DoubleSide })
					)
					ring.rotation.x = (ball.state.numInfluenced / 5) * (Math.PI / 4)
					ball.ball3d.add ring

		# Ball position
		ball.ball3d.userData.hover = false
		newPos = { 
			'x': ball.ball3d.position.x + (Math.random() * 2 - 1) * 300
			'y': ball.ball3d.position.y + (Math.random() * 2 - 1) * 300
			'z': ball.ball3d.position.z + (Math.random() * 2 - 1) * 300
		}
		@_tweenSomething ball.ball3d.position, ball.ball3d.position.clone(), newPos, 200, () =>
			ball.ball3d.userData.hoverStartFrame = @frame
			ball.ball3d.userData.startPosition   = ball.ball3d.position.clone()
			ball.ball3d.userData.hover           = true

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

		cubeInfo = { 
			'cube':cube
			#'cubeCam':cubeCam
			'posStart':cube.position.clone()
			'phase':Math.random() * Math.PI * 2
			'hoverSpeed': 1 / (0.01 + Math.random() * 80)
			'rotateSpeed': 1 / (10 + Math.random() * 40)
		}
		@instaCubes.push cubeInfo
		@newCubes.push cube

		# Replace old cubes?
		if @instaCubes.length > @opts.groupCubesEvery and @instaCubes.length % @opts.groupCubesEvery is 1
			@_replaceCubesWithMegaCube()


	_replaceCubesWithMegaCube: () ->

		console.log('num cubes', @instaCubes.length)


		# Create a mega cube
		cubeColor    = new THREE.Color()
		cubeColor.setHSL( Math.random(), 0.2, 0.2 )
		cubeGeometry = new THREE.IcosahedronGeometry 200
		cubeMaterial = new THREE.MeshLambertMaterial { 'ambient':cubeColor, 'side':THREE.DoubleSide }
		megaCube     = new THREE.Mesh cubeGeometry, cubeMaterial

		megaCubePos = new THREE.Vector3( @opts.roomSize / 2 - 200, @opts.roomSize / 2 - 200, @opts.roomSize / 2 - 200 )
		megaCubePos.applyAxisAngle(	new THREE.Vector3(1, 0, 0),	Math.random() * 2 * Math.PI	)
		megaCubePos.applyAxisAngle(	new THREE.Vector3(0, 1, 0),	Math.random() * 2 * Math.PI	)
		megaCubePos.applyAxisAngle(	new THREE.Vector3(0, 0, 1),	Math.random() * 2 * Math.PI	)
			
		#megaCubePos.multiplyScalar( @opts.roomSize / 2 )
		megaCube.position = megaCubePos

		if not @megaCubes?
			@megaCubes = []

		@megaCubes.push megaCube
		@scene.add megaCube


		# Remove old cubes
		cubeStartIndex = @cubesGrouped
		cubeEndIndex   = @cubesGrouped + @opts.cubesPerGroup

		oldCubes = @instaCubes.slice( cubeStartIndex, cubeEndIndex )
		for cubeInfo in oldCubes
			@_removeCube cubeInfo, megaCubePos.clone(), megaCube

		@cubesGrouped += cubeEndIndex - cubeStartIndex


	_removeCube: (cubeInfo, destination, megaCube) ->
		#console.log(cubeInfo)

		# Add line to cube instead of scene
		cubeInfo.cube.add( cubeInfo.cube.userData.cubeLine )

		# Send away
		cubePos = cubeInfo.cube.position
		cubeTo = cubePos.clone()
		cubeTo.multiplyScalar 100
		@_tweenSomething cubePos, cubePos.clone(), destination, 1000, () =>
			megaCube.add cubeInfo.cube.userData.cubeLine
			@scene.remove cubeInfo.cube


	_updateInstaCubes: () ->

		for cubeInfo in @instaCubes

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
			for key in Object.keys(@)
				something[key] = @[key]

		# Add possible callback
		if callback
			tween.onComplete callback

		tween.start()

	



window.Audanism.Graphic.VisualOrganism = VisualOrganism
