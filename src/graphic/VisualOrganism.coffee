###
	WebGL organism visualizer
###
class VisualOrganism


	# Constructor
	constructor: () ->
		_this = @

		# Options
		@opts = {
			'roomSize': 2000
			'roomVertices': 100
			'roomColor': 0x3AAB92
			'ballSize': 20
			'ballColor': 0xF2ED50
			'ballColorCompare': 0xED8A34
			'ballCompareTime': 1000
			'ballColorInfluence': 0xED34A0
			'ballInfluenceTime': 2000
		}

		# Init handlers
		EventDispatcher.listen 'audanism/init/organism',  @, @onInitOrgasm

		# Real-time handlers
		#$(document).on 'audanism/iteration', @onIteration
		EventDispatcher.listen 'audanism/influence/node', @, @onInfluenceNode
		EventDispatcher.listen 'audanism/compare/nodes',  @, @onCompareNodes

		@initControls()

		#$('html').addClass 'canvas-only'


	onInitOrgasm: (organism) ->
		console.log '#onInitOrgasm', organism, @
		@organism = organism

		@buildScene()


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


		# Init
		init = () =>

			# Camera && scene
			@camera = new THREE.PerspectiveCamera 50, window.innerWidth / window.innerHeight, 1, 10000
			#camera.position.z = 1000
			#@camera.position.z = 0
			@camera.position = new THREE.Vector3 @sphereSize * 2, @sphereSize / 2, @sphereSize * 2
			@camera.target = new THREE.Vector3 0, 0, 0
			@camera.lookAt @camera.target
			@camera.setLens 35

			@scene = new THREE.Scene()
			#scene.fog = new THREE.Fog( 0x050505, 2000, 4000 )

			# Container sphere
			sphere = new THREE.Mesh( new THREE.SphereGeometry(@opts.roomSize, @opts.roomVertices, @opts.roomVertices), new THREE.MeshPhongMaterial({ 'ambient': @opts.roomColor, 'side': THREE.BackSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors }) )
			@scene.add sphere

			# Make balls
			for i in [0..@numBalls-1]

				# Make ball info object
				ball = {
					ballId:     i
					pos:        new THREE.Vector3 Math.round(Math.random() * @sphereSize - (@sphereSize / 2)), Math.round(Math.random()  * @sphereSize - (@sphereSize / 2)), Math.round(Math.random() * @sphereSize - (@sphereSize / 2))
					ballSize:   @opts.ballSize
				}

				# Make ball 3d object
				ballGeometry  = new THREE.SphereGeometry ball.ballSize, 20, 20
				ballMaterial  = new THREE.MeshLambertMaterial({ 'ambient':@opts.ballColor, 'side': THREE.DoubleSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors })
				ball3d        = new THREE.Mesh ballGeometry, ballMaterial
				ball3d.ballId = ball.ballId; # Store id reference

				# Store ball 3d object in ball info object
				ball.ball3d   = ball3d

				# Position ball
				ball.ball3d.position.set ball.pos.x, ball.pos.y, ball.pos.z

				console.log ball.pos
				@scene.add ball.ball3d
				@balls[i] = ball

			console.log @balls

			# Create a plane
			#planeXZ = new THREE.Mesh( new THREE.PlaneGeometry @sphereSize * 3, @sphereSize * 3, new THREE.MeshLambertMaterial { 'color':0x22eecc, 'side': THREE.DoubleSide, 'shading': THREE.FlatShading, 'blending': THREE.AdditiveBlending, 'vertexColors': THREE.VertexColors } )
			#planeXZ.position.set 0, 0, 0
			#@scene.add planeXZ

			# lights
			@lightAmb = new THREE.AmbientLight 0xffffff
			@scene.add @lightAmb

			@lightSpot = new THREE.DirectionalLight 0xffffff, 0.2
			@lightSpot.position.set 0, 1, 1
			@scene.add @lightSpot

			@renderer = new THREE.WebGLRenderer { 'alpha':false, 'antialias':true }
			#renderer.setClearColor( 0x000000, 0 )
			@renderer.setSize window.innerWidth, window.innerHeight

			console.log @scene

			$('#container').append @renderer.domElement

		createAxis = () =>

			@axis = new THREE.AxisHelper( 500 )
			@scene.add @axis

			###
			textGeo = new THREE.TextGeometry 'Y', {
				size: 20
				height: 2
				curveSegments: 6
				font: "helvetiker"
				style: "normal"
			}
			color = new THREE.Color()
			color.setRGB(255, 250, 250)
			textMaterial = new THREE.MeshBasicMaterial({ color: color })
			text = new THREE.Mesh(textGeo , textMaterial)

			text.position.x = @axis.geometry.vertices[1].x;
			text.position.y = @axis.geometry.vertices[1].y;
			text.position.z = @axis.geometry.vertices[1].z;
			text.rotation   = @camera.rotation;
			@scene.add(text);
			###


		# Animate
		animate = () =>

			# note: three.js includes requestAnimationFrame shim
			requestAnimationFrame( Audanism.Graphic.public.animate )

			#if frame is 0
			#	@setSkyBgFromAngle(@camera.rotation.y)

			@frame++

			
			if (@keyLeft)
				@camera.rotation.y += 0.05
			if (@keyRight)
				@camera.rotation.y -= 0.05
			if (@keyUp)
				@camera.rotation.x += 0.05
			if (@keyDown)
				@camera.rotation.x -= 0.05
			
			#@camera.lookAt new THREE.Vector3 0, 0, 0

			#@camera.rotation.y += 0.02

			# Rotate camera around cluster
			@camera.position.x = Math.sin(  @frame / 200 ) * @sphereSize * 2
			@camera.position.z = Math.cos(  @frame / 200 ) * @sphereSize * 2
			#console.log @camera.position
			#@camera.rotation.y = Math.asin( @frame / 100 )
			@camera.lookAt( @camera.target )

			# Render
			@renderer.render( @scene, @camera )


		###
		function setSkyBgFromAngle(angle) {
			var angle1 = angle + Math.PI / 8,
				angle2 = angle - Math.PI / 8
			var color1 = [
					150 + Math.floor(80 * (Math.sin(angle1) / 2 + 0.5)),
					150 + Math.floor(80 * (Math.sin(angle1 + Math.PI / 3) / 2 + 0.5)),
					150 + Math.floor(80 * (Math.sin(angle1 + 2 * Math.PI / 3) / 2 + 0.5))
				],
				color2 = [
					150 + Math.floor(80 * (Math.sin(angle2) / 2 + 0.5)),
					150 + Math.floor(80 * (Math.sin(angle2 + Math.PI / 3) / 2 + 0.5)),
					150 + Math.floor(80 * (Math.sin(angle2 + 2 * Math.PI / 3) / 2 + 0.5))
				]

			$body
				.css({
					'background-image': '-webkit-linear-gradient(left, rgb(' + color1.join(',') + '), rgb(' + color2.join(',') + '))'
				})
		}
		####

		window.Audanism.Graphic.public = {
			'animate': animate
		}

		# Go
		init()
		createAxis()
		animate()

		@

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


	onIteration: () ->


	onCompareNodes: (compareData) ->
		console.log '#onCompareNodes', compareData

		for node in compareData.nodes
			ball = @balls[node.nodeId]
			@_animateComparingBall ball

	_animateComparingBall: (ball) ->
		ball.ball3d.material.ambient.setHex @opts.ballColorCompare

		setTimeout () =>
			ball.ball3d.material.ambient.setHex @opts.ballColor
		, @opts.ballCompareTime


	onInfluenceNode: (influenceData) ->
		@_animateInfluencedBall @balls[influenceData.node.node.nodeId]


	_animateInfluencedBall: (ball) ->
		ball.ball3d.material.ambient.setHex @opts.ballColorInfluence

		setTimeout () =>
			ball.ball3d.material.ambient.setHex @opts.ballColor
		, @opts.ballInfluenceTime



window.Audanism.Graphic.VisualOrganism = VisualOrganism
