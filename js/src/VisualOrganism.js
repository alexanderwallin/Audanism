// Generated by CoffeeScript 1.4.0

/*
	WebGL organism visualizer
*/


(function() {
  var VisualOrganism;

  VisualOrganism = (function() {

    function VisualOrganism() {
      var _this = this;
      _this = this;
      this.opts = {
        'cameraDistanceStart': 1600,
        'cameraDistance': 1300,
        'clusterSize': 1000,
        'roomSize': 3000,
        'roomVertices': 100,
        'roomColor': new THREE.Color(0x4A6D8A),
        'roomColor2': new THREE.Color(0x3D6D7D),
        'roomColorChaos': new THREE.Color(0x941950),
        'fogColorStart': new THREE.Color(0x999999),
        'ballSize': 10,
        'ballColor': new THREE.Color(0xF2ED50),
        'ballColorCompare': new THREE.Color(0xF24900),
        'ballCompareTime': 1000,
        'ballColorInfluence': new THREE.Color(0xED34A0),
        'ballInfluenceTime': 2000,
        'ballColorVeteran': new THREE.Color(0x1F36E0),
        'groupCubesEvery': 6,
        'cubesPerGroup': 4
      };
      this.state = {};
      this.queue = [];
      this.tweens = [];
      this.cubes = [];
      this.newCubes = [];
      this.cubeLines = [];
      this.megaCubes = [];
      this.cubesGrouped = 0;
      this.newBalls = [];
      $(window).on('resize', this.onWindowResize.bind(this));
      EventDispatcher.listen('audanism/controls/start', this, this.onStart);
      EventDispatcher.listen('audanism/init/organism', this, this.onInitOrganism);
      EventDispatcher.listen('audanism/iteration', this, this.onIteration);
      EventDispatcher.listen('audanism/compare/nodes', this, this.onCompareNodes);
      EventDispatcher.listen('audanism/influence/node', this, this.onInfluenceNode);
      EventDispatcher.listen('audanism/influence/factor/after', this, this.onInfluenceFactorAfter);
      EventDispatcher.listen('audanism/node/add', this, function(info) {
        return _this.createBalls(info.numNodes);
      });
    }

    VisualOrganism.prototype.onStart = function() {
      if (this.balls.length === 0) {
        return this.createBalls(this.numBalls);
      }
    };

    VisualOrganism.prototype.onInitOrganism = function(organism) {
      this.organism = organism;
      return this.init();
    };

    VisualOrganism.prototype.onWindowResize = function(e) {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      return this.renderer.setSize(window.innerWidth, window.innerHeight);
    };

    VisualOrganism.prototype.init = function() {
      window.Audanism.Graphic["public"] = {
        'animate': this.animate.bind(this)
      };
      this.buildScene();
      return this.animate();
    };

    VisualOrganism.prototype.buildScene = function() {
      var ballGlowMaterial, ballGlowSprite, factor, factor3d, factorColor, now, roomColor, _i, _len, _ref,
        _this = this;
      now = new Date();
      this.lastLoop = 0;
      this.thisLoop = 0;
      this.fps = 0;
      this.numBadFps = 0;
      this.camera;
      this.scene;
      this.renderer;
      this.stats;
      this.lightAmb;
      this.lightSpot;
      this.factors = [];
      this.balls = [];
      this.balls3d = [];
      this.numBalls = this.organism.getNodes().length;
      this.sphereSize = 500;
      this.frame = 0;
      this.mouseX = 0;
      this.mouseY = 0;
      this.mouseStartX = 0;
      this.mouseStartY = 0;
      this.mouseDX = 0;
      this.mouseDY = 0;
      this.mouseDown = false;
      this.keyLeft = false;
      this.keyRight = false;
      this.keyUp = false;
      this.keyDown = false;
      this.renderer = new THREE.WebGLRenderer({
        'alpha': false,
        'antialias': true
      });
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.renderer.clearColor = 0xff1190;
      this.scene = new THREE.Scene();
      this.camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 1, 20000);
      this.camera.position = new THREE.Vector3(1, 0.25, 1).multiplyScalar(this.opts.cameraDistanceStart);
      this.camera.target = new THREE.Vector3(0, 0, 0);
      this.camera.lookAt(this.camera.target);
      this.camera.setLens(35);
      this.stats = new Stats();
      $(this.stats.domElement).attr('id', 'fps-stats');
      container.appendChild(this.stats.domElement);
      this.lightAmb = new THREE.AmbientLight(0xaaaaaa);
      this.scene.add(this.lightAmb);
      this.lightSpot = new THREE.DirectionalLight(0xaaaaaa, 0.7);
      this.lightSpot.position.set(0, 1, 1);
      this.scene.add(this.lightSpot);
      this.lightSpot2 = new THREE.DirectionalLight(0xaaaaaa, 0.5);
      this.lightSpot2.position.set(0.3, 1, -1);
      this.scene.add(this.lightSpot2);
      roomColor = this.opts.roomColor.clone();
      this.room = new THREE.Mesh(new THREE.SphereGeometry(this.opts.roomSize, this.opts.roomVertices, this.opts.roomVertices / 2), new THREE.MeshPhongMaterial({
        'ambient': roomColor,
        'side': THREE.BackSide,
        'shading': THREE.FlatShading,
        'blending': THREE.AdditiveBlending,
        'vertexColors': THREE.VertexColors
      }));
      this.setDaylight();
      this.scene.add(this.room);
      setInterval(function() {
        return _this.state.shouldSetDaylight = true;
      }, 60000);
      /* Skybox
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
      */

      this.centerBall = new THREE.Mesh(new THREE.TetrahedronGeometry(10, 0), new THREE.MeshLambertMaterial({
        'ambient': 0x331177,
        'side': THREE.DoubleSide
      }));
      ballGlowMaterial = new THREE.SpriteMaterial({
        map: new THREE.ImageUtils.loadTexture('img/glow.png'),
        useScreenCoordinates: false,
        color: 0x222222,
        transparent: false,
        blending: THREE.AdditiveBlending
      });
      ballGlowSprite = new THREE.Sprite(ballGlowMaterial);
      ballGlowSprite.scale.set(50, 50, 1.0);
      this.centerBall.add(ballGlowSprite);
      this.scene.add(this.centerBall);
      _ref = this.organism.getFactors();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        factor = _ref[_i];
        factorColor = new THREE.Color();
        factorColor.setHSL(factor.factorType / this.organism.getFactors().length, 0.6, 0.7);
        factor3d = new THREE.Mesh(new THREE.CylinderGeometry(50, 0, factor.factorValue * 3), new THREE.MeshLambertMaterial({
          'ambient': factorColor,
          'side': THREE.FrontSide
        }));
        factor3d.position.set(randomInt(0, 1) === 1 ? randomInt(-800, -600) : randomInt(600, 800), 0, randomInt(0, 1) === 1 ? randomInt(-800, -600) : randomInt(600, 800));
        factor3d.userData = {
          'isModifying': false,
          'startPosition': factor3d.position.clone(),
          'hover': true,
          'hoverStartFrame': 0,
          'initialValue': factor.factorValue,
          'baseColor': factor3d.material.ambient.clone()
        };
        factor3d.dynamic = true;
        this.factors[factor.factorType] = factor3d;
        this.scene.add(factor3d);
      }
      this.orbitControls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
      this.orbitControls.autoRotate = true;
      this.orbitControls.autoRotateSpeed = -1;
      return $('#canvas-wrap').css('opacity', 0).append(this.renderer.domElement).fadeTo(1000, 1.0);
    };

    VisualOrganism.prototype.animate = function() {
      var ball, cube, factor, factor3d, line, lineGeometry, lineMaterial, megaCube, _i, _j, _k, _l, _len, _len1, _len2, _len3, _moveFactor, _ref, _ref1, _ref2, _ref3,
        _this = this;
      requestAnimationFrame(Audanism.Graphic["public"].animate);
      this.thisLoop = new Date();
      if (this.lastLoop > 0) {
        this.fps = 1000 / (this.thisLoop - this.lastLoop);
      } else {
        this.fps = 60;
      }
      this.lastLoop = this.thisLoop;
      if (this.fps < 20) {
        this.numBadFps++;
        EventDispatcher.trigger('audanism/performance/badfps', this.fps);
      } else {
        this.numBadFps = 0;
        EventDispatcher.trigger('audanism/performance/goodfps', this.fps);
      }
      if (this.numBadFps >= 5) {
        EventDispatcher.trigger('audanism/performance/bad', this.fps);
      }
      this.frame++;
      EventDispatcher.trigger('audanism/graphic/update', this.frame);
      if (this.state.shouldSetDaylight) {
        this.setDaylight();
        this.state.shouldSetDaylight = false;
      }
      _moveFactor = function(factorType) {
        var factor, factor3d;
        factor = _this.organism.getFactorOfType(factorType);
        factor3d = _this.factors[factorType];
        factor3d.userData.hover = false;
        factor3d.userData.isModifying = true;
        return _this._tweenSomething(factor3d.position, {
          'y': factor3d.position.y
        }, {
          'y': (1000 - factor.disharmony) / 2
        }, 1000, function() {
          factor3d.userData.startPosition = factor3d.position.clone();
          factor3d.userData.hover = true;
          return factor3d.userData.isModifying = false;
        });
      };
      _ref = this.organism.getFactors();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        factor = _ref[_i];
        factor3d = this.factors[factor.factorType];
        if (!factor3d.userData.isModifying && this.frame > 10) {
          _moveFactor(factor.factorType);
        } else if (factor3d.userData.hover) {
          factor3d.position.y = factor3d.userData.startPosition.y + 200 * Math.sin((this.frame - factor3d.userData.hoverStartFrame) / (10 * factor.factorValue));
        }
      }
      _ref1 = this.balls;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        ball = _ref1[_j];
        if (ball.ball3d.userData.hover) {
          ball.ball3d.position.y = ball.ball3d.userData.startPosition.y + Math.sin(ball.hoverPhase + (this.frame - ball.ball3d.userData.hoverStartFrame) * ball.hoverSpeed) * 15;
        }
      }
      if (this.instaCubes != null) {
        this._updateInstaCubes();
      }
      if (this.newCubes.length > 0) {
        _ref2 = this.newCubes;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          cube = _ref2[_k];
          this.cubes.push(cube);
          this.scene.add(cube);
          lineGeometry = new THREE.Geometry();
          lineGeometry.vertices.push(new THREE.Vector3(0, 0, 0));
          lineGeometry.vertices.push(cube.position.clone());
          lineMaterial = new THREE.LineBasicMaterial({
            'color': 0xE3105A,
            'opacity': 0.3
          });
          line = new THREE.Line(lineGeometry, lineMaterial);
          this.scene.add(line);
          cube.userData.cubeLine = line;
        }
        this.newCubes = [];
      }
      _ref3 = this.megaCubes;
      for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
        megaCube = _ref3[_l];
        megaCube.rotation.x += 0.003;
        megaCube.rotation.z += 0.0007;
      }
      if (this.frame % 10 === 1) {
        this.room.material.ambient.offsetHSL(0.0001, 0, 0);
      }
      TWEEN.update();
      this.stats.update();
      this.orbitControls.update();
      return this.renderer.render(this.scene, this.camera);
    };

    VisualOrganism.prototype.addToQueue = function(fn, args) {
      return this.queue.push({
        'fn': fn,
        'args': args
      });
    };

    VisualOrganism.prototype.runQueue = function() {
      var action, _i, _len, _ref, _results;
      _ref = this.queue;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        action = _ref[_i];
        _results.push(action.fn.call(this, action.args));
      }
      return _results;
    };

    VisualOrganism.prototype.onIteration = function(influenceInfo) {
      var ball, ballScaleTo, cell, cells, disharmony, factorChangeAvg, factorChangeSum, newBallScale, newPos, node, organism, relativeDisharmony, tweenFrom, tweenTo, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _results,
        _this = this;
      organism = influenceInfo.organism;
      disharmony = organism.getDisharmonyHistoryData();
      if (disharmony.length === 0) {
        return;
      }
      disharmony = disharmony[disharmony.length - 1];
      if (!(this.opts.initialDisharmonyData != null)) {
        this.opts.initialDisharmonyData = disharmony;
      }
      relativeDisharmony = organism.getDisharmonyChange(10, 'actual');
      this.largestDistance = 0;
      _ref = this.balls;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ball = _ref[_i];
        if (this.frame % 4 === 0) {
          newPos = ball.pos.clone();
          newPos.multiplyScalar(relativeDisharmony);
          tweenFrom = ball.ball3d.position.clone();
          tweenTo = {
            'x': newPos.x,
            'y': newPos.y,
            'z': newPos.z
          };
          ball.ball3d.userData.hover = false;
          this._tweenSomething(ball.ball3d.position, tweenFrom, tweenTo, 100, function() {
            return ball.ball3d.userData.hover = true;
          });
        }
        if (ball.ball3d.position.length() > this.largestDistance) {
          this.largestDistance = ball.ball3d.position.length();
        }
      }
      this._tweenCameraDistance(this.largestDistance * (this.opts.cameraDistanceStart / this.opts.clusterSize));
      _ref1 = this.organism.getNodes();
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        node = _ref1[_j];
        cells = node.getCells();
        ball = this.balls[node.nodeId];
        if (this.frame - ball.ball3d.userData.bornAt > 30) {
          factorChangeSum = 0;
          for (_k = 0, _len2 = cells.length; _k < _len2; _k++) {
            cell = cells[_k];
            factorChangeSum += organism.getDisharmonyChangeForFactor(cell.factorType, 20);
          }
          factorChangeAvg = factorChangeSum / cells.length;
          newBallScale = Math.min(Math.pow(factorChangeAvg, 2), 10);
          ballScaleTo = {
            'x': newBallScale,
            'y': newBallScale,
            'z': newBallScale
          };
          _results.push(this._tweenSomething(ball.ball3d.scale, ball.ball3d.scale.clone(), ballScaleTo, 200));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    VisualOrganism.prototype.setDaylight = function() {
      var darken, minutesFromMidday, minutesOfDay, now, roomColor;
      now = new Date();
      roomColor = this.opts.roomColor.clone();
      minutesOfDay = now.getHours() * 60 + now.getMinutes();
      minutesFromMidday = minutesOfDay > 720 ? minutesOfDay - 720 : 720 - minutesOfDay;
      darken = 0.5 * minutesFromMidday / 720;
      console.log('darken', darken);
      console.log('minutes from midday', minutesFromMidday);
      roomColor.offsetHSL(0, 0, -darken);
      return this.room.material.ambient = roomColor;
    };

    VisualOrganism.prototype.createBalls = function(numBalls) {
      var ball, ball3d, ballGeometry, ballMaterials, i, _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = numBalls - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        ball = {
          ballId: this.balls.length,
          hello: "hello. i am ball no " + i + ".",
          direction: new THREE.Vector3(2 * Math.random() - 1, 2 * Math.random() - 1, 2 * Math.random() - 1),
          ballSize: this.opts.ballSize,
          hoverPhase: Math.random() * Math.PI * 2,
          hoverSpeed: 1 / (50 + Math.random() * 100),
          state: {
            numInfluenced: 0,
            hover: true
          },
          ref: {
            numInfluenced: 0
          }
        };
        ball.pos = new THREE.Vector3(ball.direction.x * Math.random() * this.opts.clusterSize, ball.direction.y * Math.random() * this.opts.clusterSize, ball.direction.z * Math.random() * this.opts.clusterSize);
        ball.currPos = ball.pos.clone();
        ball.changes = {};
        ballGeometry = new THREE.SphereGeometry(ball.ballSize, 20, 10);
        ballMaterials = [
          new THREE.MeshLambertMaterial({
            'ambient': this.opts.ballColor.clone(),
            'side': THREE.DoubleSide,
            'shading': THREE.FlatShading,
            'blending': THREE.AdditiveBlending,
            'vertexColors': THREE.VertexColors
          }), new THREE.MeshPhongMaterial({
            'color': 0xffffff,
            'specular': 0xffaaaa
          })
        ];
        ball3d = new THREE.Mesh(ballGeometry, ballMaterials[0]);
        ball3d.ballId = ball.ballId;
        ball3d.position = ball.pos.clone();
        ball3d.userData.hover = true;
        ball3d.userData.startPosition = ball3d.position.clone();
        ball3d.userData.hoverStartFrame = 0;
        ball3d.userData.bornAt = this.frame;
        ball3d.scale.set(0, 0, 0);
        this.scene.add(ball3d);
        this._tweenSomething(ball3d.scale, {
          'x': 0,
          'y': 0,
          'z': 0
        }, {
          'x': 1,
          'y': 1,
          'z': 1
        }, 1000);
        this.balls[ball.ballId] = ball;
        _results.push(ball.ball3d = ball3d);
      }
      return _results;
    };

    VisualOrganism.prototype.onCompareNodes = function(compareData) {
      var node, _i, _len, _ref, _results;
      _ref = compareData.nodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        _results.push(this._animateComparingBall(this.balls[node.nodeId]));
      }
      return _results;
    };

    VisualOrganism.prototype._animateComparingBall = function(ball) {
      var ballColor, ballColorCompare, newPos, target,
        _this = this;
      target = ball.ball3d.material.ambient;
      ballColor = target.clone();
      ballColorCompare = {
        'r': this.opts.ballColorCompare.r,
        'g': this.opts.ballColorCompare.g,
        'b': this.opts.ballColorCompare.b
      };
      this._tweenBallColor(ball, ballColor.clone(), this.opts.ballColorCompare.clone(), 200, function() {
        return _this._tweenBallColor(ball, _this.opts.ballColorCompare.clone(), ballColor.clone(), 500);
      });
      ball.state.hover = false;
      newPos = {
        'x': ball.ball3d.position.x + (Math.random() * 2 - 1) * 15,
        'y': ball.ball3d.position.y + (Math.random() * 2 - 1) * 15,
        'z': ball.ball3d.position.z + (Math.random() * 2 - 1) * 15
      };
      return this._tweenSomething(ball.ball3d.position, ball.ball3d.position.clone(), newPos, 30, function() {
        ball.currPos = ball.ball3d.position.clone();
        return ball.state.hover = true;
      });
    };

    VisualOrganism.prototype.onInfluenceNode = function(influenceData) {
      var _this = this;
      if (!influenceData.node.node) {
        return;
      }
      this._animateInfluencedBall(this.balls[influenceData.node.node.nodeId]);
      if (influenceData.meta.current === 1 && (influenceData.meta.source != null) && influenceData.meta.source === 'instagram') {
        this._spawnInstaCube.bind(this);
        return setTimeout(function() {
          return _this._spawnInstaCube(influenceData);
        }, 500);
      }
    };

    VisualOrganism.prototype.onInfluenceFactorAfter = function(influenceData) {
      var factor, factor3d, newColor, _afterFactorAnimation,
        _this = this;
      factor = influenceData.factor.factor;
      factor3d = this.factors[factor.factorType];
      factor3d.userData.hover = false;
      factor3d.userData.isModifying = true;
      _afterFactorAnimation = function() {
        var existingToruses, lastTorus, torus, torusColor, torusMargin, torusRadius, torusSize;
        if (!factor3d.userData.toruses) {
          factor3d.userData.toruses = [];
        }
        existingToruses = factor3d.userData.toruses;
        torusMargin = 20;
        torusSize = 10;
        if (existingToruses.length > 0) {
          lastTorus = existingToruses[existingToruses.length - 1];
          torusColor = lastTorus.material.ambient.clone();
          torusRadius = lastTorus.geometry.radius;
          torusSize = lastTorus.geometry.tube;
        } else {
          torusColor = factor3d.material.ambient.clone();
          torusRadius = factor3d.geometry.radiusTop;
          torusSize = torusSize;
        }
        torusColor.offsetHSL(0.05, -0.1, 0);
        torusRadius *= 0.96;
        torusSize *= 0.9;
        torus = new THREE.Mesh(new THREE.TorusGeometry(torusRadius, torusSize), new THREE.MeshLambertMaterial({
          'ambient': torusColor,
          'side': THREE.FrontSide
        }));
        torus.position.y = (factor3d.geometry.height / 2) + (torusMargin + existingToruses.length * (torusMargin + torusSize));
        torus.rotation.x = Math.PI / 2;
        torus.scale.set(0, 0, 0);
        factor3d.userData.toruses.push(torus);
        factor3d.add(torus);
        _this._tweenSomething(torus.scale, {
          'x': 0,
          'y': 0,
          'z': 0
        }, {
          'x': 1,
          'y': 1,
          'z': 1
        }, 1000);
        return factor3d.userData.isModifying;
      };
      factor3d.scale.y = factor.factorValue / factor3d.userData.initialValue;
      if (influenceData.meta.sourceAttr === 'wind') {
        this._tweenSomething(factor3d.rotation, {
          'z': factor3d.rotation.z
        }, {
          'z': influenceData.factor.value
        }, 300, _afterFactorAnimation);
      } else if (influenceData.meta.sourceAttr === 'temperature') {
        newColor = factor3d.userData.baseColor.clone();
        newColor.offsetHSL(0, influenceData.factor.value / 5, 0);
        this._tweenSomething(factor3d.material.ambient, factor3d.material.ambient.clone(), newColor, 300, _afterFactorAnimation);
      }
      return this._tweenSomething(factor3d.position, factor3d.position.clone(), {
        'x': (randomInt(0, 1) === 1 ? -100 : 100),
        'y': (1000 - factor.disharmony) / 2
      }, 300, function() {
        factor3d.userData.startPosition = factor3d.position.clone();
        factor3d.userData.hoverStartFrame = _this.frame;
        return factor3d.userData.hover = true;
      });
    };

    VisualOrganism.prototype._animateInfluencedBall = function(ball) {
      var ballColor, ballColorInfluence, newPos, target,
        _this = this;
      target = ball.ball3d.material.ambient;
      ballColor = target.clone();
      ballColorInfluence = {
        'r': this.opts.ballColorInfluence.r,
        'g': this.opts.ballColorInfluence.g,
        'b': this.opts.ballColorInfluence.b
      };
      this._tweenSomething(target, target.clone(), this.opts.ballColorInfluence.clone(), 200, function() {
        return _this._tweenSomething(target, _this.opts.ballColorInfluence.clone(), target.clone(), 200, function() {
          var nextColor, ring, ringRadius, routine;
          ball.state.numInfluenced += 1;
          routine = (ball.state.numInfluenced % 5) / 5;
          ball.currPos = ball.ball3d.position.clone();
          ball.state.hover = true;
          nextColor = _this.opts.ballColor.clone();
          nextColor.lerp(_this.opts.ballColorVeteran.clone(), routine);
          _this._tweenSomething(ball.ball3d.material.ambient, ball.ball3d.material.ambient.clone(), {
            'r': nextColor.r,
            'g': nextColor.g,
            'b': nextColor.b
          }, 10);
          if (routine === 0) {
            ringRadius = 3 * ball.ball3d.geometry.radius;
            ring = new THREE.Mesh(new THREE.CylinderGeometry(ringRadius, ringRadius, 1), new THREE.MeshLambertMaterial({
              'ambient': ball.ball3d.material.ambient.clone(),
              'transparent': true,
              'opacity': 0.3,
              'side': THREE.DoubleSide
            }));
            ring.rotation.x = (ball.state.numInfluenced / 5) * (Math.PI / 4);
            return ball.ball3d.add(ring);
          }
        });
      });
      ball.ball3d.userData.hover = false;
      newPos = {
        'x': ball.ball3d.position.x + (Math.random() * 2 - 1) * 300,
        'y': ball.ball3d.position.y + (Math.random() * 2 - 1) * 300,
        'z': ball.ball3d.position.z + (Math.random() * 2 - 1) * 300
      };
      return this._tweenSomething(ball.ball3d.position, ball.ball3d.position.clone(), newPos, 200, function() {
        ball.ball3d.userData.hoverStartFrame = _this.frame;
        ball.ball3d.userData.startPosition = ball.ball3d.position.clone();
        return ball.ball3d.userData.hover = true;
      });
    };

    VisualOrganism.prototype._spawnInstaCube = function(influenceData) {
      var cube, cubeGeometry, cubeInfo, cubeMaterials;
      cubeGeometry = new THREE.CubeGeometry(30, 30, 30);
      cubeMaterials = [
        new THREE.MeshLambertMaterial({
          'ambient': 0x0E1B21,
          'side': THREE.DoubleSide
        })
      ];
      /*
      		cubeMaterials [
      			new THREE.MeshLambertMaterial { 'ambient':0x07325E, 'side':THREE.DoubleSide }
      			new THREE.MeshPhongMaterial { 'ambient':0x07325E, 'side':THREE.DoubleSide }
      		]
      */

      cube = new THREE.Mesh(cubeGeometry, cubeMaterials[0]);
      cube.position.set((1 - 2 * Math.random()) * this.opts.clusterSize * 0.5 * (1.5 - Math.random()), (1 - 2 * Math.random()) * this.opts.clusterSize * (1.5 - Math.random()), (1 - 2 * Math.random()) * this.opts.clusterSize * (1.5 - Math.random()));
      cube.rotation.set(Math.random(), Math.random(), Math.random());
      if (!(this.instaCubes != null)) {
        this.instaCubes = [];
      }
      cubeInfo = {
        'cube': cube,
        'posStart': cube.position.clone(),
        'phase': Math.random() * Math.PI * 2,
        'hoverSpeed': 1 / (0.01 + Math.random() * 80),
        'rotateSpeed': 1 / (10 + Math.random() * 40)
      };
      this.instaCubes.push(cubeInfo);
      this.newCubes.push(cube);
      if (this.instaCubes.length > this.opts.groupCubesEvery && this.instaCubes.length % this.opts.groupCubesEvery === 1) {
        return this._replaceCubesWithMegaCube();
      }
    };

    VisualOrganism.prototype._replaceCubesWithMegaCube = function() {
      var cubeColor, cubeEndIndex, cubeGeometry, cubeInfo, cubeMaterial, cubeStartIndex, megaCube, megaCubePos, oldCubes, _i, _len;
      cubeColor = new THREE.Color();
      cubeColor.setHSL(Math.random(), 0.2, 0.2);
      cubeGeometry = new THREE.IcosahedronGeometry(200);
      cubeMaterial = new THREE.MeshLambertMaterial({
        'ambient': cubeColor,
        'side': THREE.DoubleSide
      });
      megaCube = new THREE.Mesh(cubeGeometry, cubeMaterial);
      megaCubePos = new THREE.Vector3(this.opts.roomSize / 2 - 200, this.opts.roomSize / 2 - 200, this.opts.roomSize / 2 - 200);
      megaCubePos.applyAxisAngle(new THREE.Vector3(1, 0, 0), Math.random() * 2 * Math.PI);
      megaCubePos.applyAxisAngle(new THREE.Vector3(0, 1, 0), Math.random() * 2 * Math.PI);
      megaCubePos.applyAxisAngle(new THREE.Vector3(0, 0, 1), Math.random() * 2 * Math.PI);
      megaCube.position = megaCubePos;
      if (!(this.megaCubes != null)) {
        this.megaCubes = [];
      }
      this.megaCubes.push(megaCube);
      this.scene.add(megaCube);
      cubeStartIndex = this.cubesGrouped;
      cubeEndIndex = this.cubesGrouped + this.opts.cubesPerGroup;
      oldCubes = this.instaCubes.slice(cubeStartIndex, cubeEndIndex);
      for (_i = 0, _len = oldCubes.length; _i < _len; _i++) {
        cubeInfo = oldCubes[_i];
        this._removeCube(cubeInfo, megaCubePos.clone(), megaCube);
      }
      return this.cubesGrouped += cubeEndIndex - cubeStartIndex;
    };

    VisualOrganism.prototype._removeCube = function(cubeInfo, destination, megaCube) {
      var cubePos, cubeTo,
        _this = this;
      cubeInfo.cube.add(cubeInfo.cube.userData.cubeLine);
      cubePos = cubeInfo.cube.position;
      cubeTo = cubePos.clone();
      cubeTo.multiplyScalar(100);
      return this._tweenSomething(cubePos, cubePos.clone(), destination, 1000, function() {
        cubeInfo.cube.userData.cubeLine.material.color = 0x000000;
        megaCube.add(cubeInfo.cube.userData.cubeLine);
        return _this.scene.remove(cubeInfo.cube);
      });
    };

    VisualOrganism.prototype._updateInstaCubes = function() {
      var cubeInfo, _i, _len, _ref, _results;
      _ref = this.instaCubes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cubeInfo = _ref[_i];
        _results.push(cubeInfo.cube.rotation.x += cubeInfo.rotateSpeed);
      }
      return _results;
    };

    VisualOrganism.prototype._tweenBall = function(ball, from, to, duration) {
      var tween;
      duration = duration || 300;
      tween = new TWEEN.Tween(from).to(to, duration);
      this.tweens.push(tween);
      tween.easing(TWEEN.Easing.Quadratic.InOut);
      tween.onUpdate(function() {
        return ball.ball3d.position.set(this.x, this.y, this.z);
      });
      return tween.start();
    };

    VisualOrganism.prototype._tweenBallSize = function(ball, from, to, duration, callback) {
      var tween;
      tween = new TWEEN.Tween({
        from: from
      }).to(to, duration);
      this.tweens.push(tween);
      tween.easing(TWEEN.Easing.Linear.None);
      tween.onUpdate(function() {
        return ball.ball3d.scale.set(this.x, this.y, this.z);
      });
      return tween.start();
    };

    VisualOrganism.prototype._tweenCameraDistance = function(to) {
      var tween, _this;
      _this = this;
      tween = new TWEEN.Tween({
        'distance': this.opts.cameraDistance
      }).to({
        'distance': to
      }, 400);
      this.tweens.push(tween);
      tween.easing(TWEEN.Easing.Quadratic.InOut);
      tween.onUpdate(function() {
        return _this.opts.cameraDistance = this.distance;
      });
      return tween.start();
    };

    VisualOrganism.prototype._tweenBallColor = function(ball, fromColor, toColor, duration, callback) {
      var colorFrom, colorTo, tween;
      colorFrom = {
        'r': fromColor.r,
        'g': fromColor.g,
        'b': fromColor.b
      };
      colorTo = {
        'r': toColor.r,
        'g': toColor.g,
        'b': toColor.b
      };
      tween = new TWEEN.Tween(colorFrom).to(colorTo, duration).easing(TWEEN.Easing.Quadratic.InOut);
      this.tweens.push(tween);
      tween.onUpdate(function() {
        if (ball.ball3d.children.length > 0) {
          return ball.ball3d.children[0].material.ambient.setRGB(this.r, this.g, this.b);
        } else {
          return ball.ball3d.material.ambient.setRGB(this.r, this.g, this.b);
        }
      });
      if (callback) {
        tween.onComplete(callback);
      }
      return tween.start();
    };

    VisualOrganism.prototype._tweenColor = function(targetColor, fromColor, toColor, duration, callback) {
      var colorFrom, colorTo, tween;
      colorFrom = {
        'r': fromColor.r,
        'g': fromColor.g,
        'b': fromColor.b
      };
      colorTo = {
        'r': toColor.r,
        'g': toColor.g,
        'b': toColor.b
      };
      tween = new TWEEN.Tween(colorFrom).to(colorTo, duration).easing(TWEEN.Easing.Quadratic.InOut);
      this.tweens.push(tween);
      tween.onUpdate(function() {
        return targetColor.setRGB(this.r, this.g, this.b);
      });
      if (callback) {
        tween.onComplete(callback);
      }
      return tween.start();
    };

    VisualOrganism.prototype._tweenSomething = function(something, from, to, duration, callback) {
      var tween;
      tween = new TWEEN.Tween(from).to(to, duration).easing(TWEEN.Easing.Quadratic.InOut);
      this.tweens.push(tween);
      tween.onUpdate(function() {
        var key, _i, _len, _ref, _results;
        _ref = Object.keys(this);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          key = _ref[_i];
          _results.push(something[key] = this[key]);
        }
        return _results;
      });
      if (callback) {
        tween.onComplete(callback);
      }
      return tween.start();
    };

    return VisualOrganism;

  })();

  window.Audanism.Graphic.VisualOrganism = VisualOrganism;

}).call(this);
