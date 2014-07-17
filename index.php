<?php
/**
 * Audanism index.php.
 */

// Fake localhost
$runLocal = @$_GET['local'] == 'yes';

// Check environment
$isProduction = preg_match("/\.com/", $_SERVER['HTTP_HOST']);

?><!DOCTYPE html>
<!--[if lt IE 7]>	  <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>		 <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>		 <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js canvas-only"> <!--<![endif]-->
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

		<!-- Meta -->
		<title>Audanism - An audiovisual online quasi-organism</title>
		<meta name="description" content="Audanism is an online art piece and experiment striving to create an, in some way, alive and self-aware online audiovisual organism.">
		<meta property="og:image" content="http://<?php echo $_SERVER['HTTP_HOST']; ?>/img/audanism-og-image2.jpg">
		<meta name="viewport" content="width=device-width">

		<!-- Icon -->
		<link rel="shortcut icon" href="img/favicon.jpg">

		<!-- CSS -->
		<link rel="stylesheet" href="css/normalize.css">
		<link rel="stylesheet" href="css/main.css?v=20140717-1">
	</head>
	<body class="paused">

		<div id="container">

			<!-- Header -->
			<header id="header">
				<div id="title">Audanism</div>
				<div id="top-author">By Alexander Wallin</div>
			</header>

			<!-- Wiki -->
			<div id="wiki">

				<!-- Table of contents -->
				<nav id="table-of-contents">
					<a href="#intro" class="active" data-target-tab="1">Introduction</a>
					<a href="#project-outline" data-target-tab="2">Project outline</a>
					<a href="#add-your-influence" data-target-tab="3">Add your influence</a>

					<a href="#close" class="wiki-close" data-toggle-wiki="hide">Close &nbsp; &times;</a>
				</nav>

				<!-- Wiki contents -->
				<div id="wiki-content">

					<!-- Introduction -->
					<div id="intro" class="tab-content active" data-tab="1">
						<h1>Audanism</h1>
						
						<p>Audanism is an online art piece and experiment striving to create an, in some way, alive and self-aware online audiovisual organism. It is a way of studying views on life and data simultaneously through philosophical, psychological and technical approaches and analysis.</p>

						<p>Here you may spawn a tiny piece of online, computerized life.</p>

						<p class="note">Note: This site is developed using modern web technologies (WebGL and Web Audio API) for the Google Chrome desktop web browser and needs a lot of computer juice to run.</p>

						<p class="note">Audanism is created by <a href="http://alexanderwallin.com" target="_blank">Alexander Wallin</a>.</p>

						<div id="intro-actions">
							<a id="intro-btn-start" href="#start">Initiate life</a>
						</div>
					</div>

					<!-- Project outline -->
					<div id="project-outline" class="tab-content" data-tab="2">
						<h1>Audanism</h1>

						<h2>Summary</h2>
						<p><strong>Audanism is an experimet striving to create an, in some way, alive and self-aware audiovisual organism.</strong> It is a way of studying views on life and data simultaneously using philosophical, psychological and technical approaches and analysis.</p>
						<p class="note">You will also find this outline at <a href="//alexanderwallin.com/art/audanism" target="_blank">alexanderwallin.com/art/audanism</a>.</p>
						<h2>What is an organism?</h2>
						<p>In contrast to reconstruation of physiological organisms, f.i. in development of artificial intelligense, this project aims to invent a lifeform that meets criteria similar to that of the physiological organism (metabolism, evolutionary reproduction etc.), but from a more general philosophical entry point, centered upon self-development and the programmatical environment.</p>
						<p>An audanism has to meet the following criteria:</p>
						<ol>
						<li>it is affected, directly or indirectly, by a surrounding environment;</li>
						<li>it has at least on purpose of living (raison d'être); and</li>
						<li>it alters its structure or its structure's components in quest to attain its purpose of living (decision making/self-development).</li>
						</ol>
						<h3>Surroundings and environment</h3>
						<p>The audanism lives in a bubble on the Internet, literally. As such it has both a direct and indirect environment; the bubble and the rest of the web.</p>
						<p>It is mostly affected and influnced by the indirect environment through information available via APIs. How different influencial sources affect the audanism is largely arbitrary, but its influence can be direct either towards factors or node cells.</p>
						<h3>Purpose of life</h3>
						<p>The audanism's continuous goal is to keep an as harmonic state as possible. Harmony is here a value calculated from the relations between its different components' various attributes and their values. The algorithm used for these calculations are in most senses completely arbitrary, which, arguably, the conditions of the real world are too, as long as you don't believe in one or more Makers.</p>
						<h3>Self-development</h3>
						<p>By reviewing and modifying the relations between its components' various attributes and values, the audanism performs a form of self-development, where all possible actions resulting in greater harmony are taken. There are, of course, limitations in the number of possible actions and in the evaluation frequency (more on that further down).</p>
						<p>During strong trends of negative harmony development, the audanism can be thrown into stress mode. When in stress mode, the self-evaluation algorithm is less accurate. One could say that it panics and recedes into short-term thinking.</p>
						<h2>Structure</h2>
						<p>The audanism consists of five factors and some number of nodes, which themselves consists of cells.</p>
						<h3>The five factors</h3>
						<p>The five factors are based on the psychological theory about the Big Five personality traits, where each factor corresponds to a trait.</p>
						<p>The factors have fixed interrelationships; each factor has a set value for each of the other factors which constitutes how well it fits with that factor. This is accounted for when calculating harmony.</p>
						<h3>Nodes and cells</h3>
						<p>A node is a container of between two and five cells, where each cell corresponds to a factor through a numeric value. Cells within a node must have unique corresponding factors.</p>
						<h2>Harmony calculation and boost</h2>
						<p>The audanism's harmony is calculated through two methods:</p>
						<ul>
						<li>the elaborate method (actual harmony); and</li>
						<li>the simplified method (estimated harmony).</li>
						</ul>
						<p>The methods are used for both present and possible harmonic levels. Which method is used for evaluation depends on whether the audanism is in stress mode or not.</p>
						<p>It is always the actual harmony that represents the audanism's true state.</p>
						<h3>Simplified method (estimated harmony)</h3>
						<p>The simplified method sums the differences between cells' factor values and the corresponding factors in all nodes inside the audanism. This method is used while in stress mode.</p>
						<h3>Elaborate method (actual harmony)</h3>
						<p>The elaborate method performs the steps of the simplified method, but takes into account the factor interrelationships and adjusts the values of harmony thereafter. This method is used while in normal state (not in stress mode).</p>
						<h3>Actions an application of calculation methods</h3>
						<p>In every evaluation the audanism looks at cells from two nodes. If the nodes have one or more cells with common corresponding factor, those are brought to comparison between each other. For each comparison there are two possible actions:</p>
						<ol>
						<li>Move a value of one (1) from the cell in the first node to the corresponding cell in the second node.</li>
						<li>Move a value of one (1) from the cell in the second node to the corresponding cell in the first node.</li>
						</ol>
						<p>The beneficiance is determined by comparing pre-calculations of each action (i.e. simulating them and storing the resulting overall harmony), where the one with the highest resulting harmony is chosen. The calculation method used here is, like stated above, determined by the audanisms current state. Herein is a key aspect: <strong>when in stress mode, the audanism makes less accurate forecasts</strong>. In its normal state, the predictions will always be the best possible.</p>
						<h2>Embodiment</h2>
						<p>The audanism's components are in great extent directly visually represented in a spheric space, where changes in form and movement pictures their own and the audanism's state. The visualization also has marks of experience, where past outer influences are collected in shapes that perhaps could be seen as scars.</p>
						<p>Through sonic layers, the audanism's gets its pulse, through which rate of inner change, current condition and outer influences are directly perceivable. This composition is designed so that ones own (human) associations on what is perceived as harmonious or not has as little impact on the soundscape as possible, this due to the main purpose of the experiment to invent life, not reconstruct it.</p>
					</div>

					<!-- Add your influnce -->
					<div id="add-your-influence" class="tab-content" data-tab="3">
						<h1>Audanism</h1>

						<h2>Add your influence</h2>

						<p>Audanism is currently influenced by weather around the world and by Instagram photos tagged with <code>#art</code> and <code>#audanism</code>. To add your own influence, post a photo and tag it with <code>#audanism</code>, and you should soon see it in effect.</p>

						<!-- TODO: Credits -->
					</div>
				</div>
			</div>

			<!-- Stats and feeds -->
			<aside id="stats-wrap">

				<!-- Coziness -->
				<div id="cozy-stats" class="stats-block">
					<div class="stats-title">Right now</div>

					<div class="stats-block-content">
						<p class="time-of-day early-morning">It's early in the morning.</p>
						<p class="time-of-day morning">It's morning.</p>
						<p class="time-of-day midday">It's lunchtime.</p>
						<p class="time-of-day afternoon">It's in the afternoon.</p>
						<p class="time-of-day evening">It's evening time.</p>
						<p class="time-of-day night">It's night time.</p>
					</div>
				</div>

				<div id="stats-tables">

					<!-- Organism stats -->
					<table id="organism-stats" class="stats-table">
						<thead>
							<tr>
								<th class="title">Orgnaism</th>
								<th class="stress-mode">
									<div class="stress-mode-indicator" title="Stress mode"></div>
								</th>
							</tr>
						</thead>

						<tbody class="stats-block-content">
							<tr id="summed-disharmony">
								<td class="label" title="Summed organism disharmony">EST</td>
								<td class="value">0</td>
							</tr>

							<tr id="actual-disharmony">
								<td class="label" title="Real organism disharmony, depending on state">REAL</td>
								<td class="value">0</td>
							</tr>
						</tbody>
					</table>

					<!-- Factor stats -->
					<table id="factor-stats" class="stats-table">
						<thead>
							<tr>
								<th class="title">Factors</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>
							</tr>
						</thead>

						<tbody class="stats-block-content">
							<tr id="factor-values">
								<td class="label">FV</td>
								<td class="value" data-factor="1">0</td>
								<td class="value" data-factor="2">0</td>
								<td class="value" data-factor="3">0</td>
								<td class="value" data-factor="4">0</td>
								<td class="value" data-factor="5">0</td>
							</tr>

							<tr id="factor-disharmonies">
								<td class="label">FD</td>
								<td class="value" data-factor="1">0</td>
								<td class="value" data-factor="2">0</td>
								<td class="value" data-factor="3">0</td>
								<td class="value" data-factor="4">0</td>
								<td class="value" data-factor="5">0</td>
							</tr>
						</tbody>
					</table>
				</div>

				<!-- Influences -->
				<div id="influences" class="stats-block">
					<div class="stats-title">Influences</div>

					<div class="stats-block-content">
						<div class="influence template">
							<div class="influence-type"></div>
							<div class="influence-source stats-label"></div>
							<div class="influence-summary"></div>
							<div class="influence-link"></div>
							<div class="influence-value"></div>
						</div>
					</div>

					<div id="interact">
						<div id="interact-btn" data-target-tab="3">Add your influence</div>
					</div>
				</div>
			</aside>

			<!-- Controls -->
			<div id="controls">
				<a class="btn" href="#start">Start</a>
				<a class="btn" href="#pause">Pause</a>
				<!-- <a class="btn" href="#step" style="display: none;">Step ></a> -->

				<div class="controls-sep"></div>

				<a class="btn" href="#toggleview">Clean view</a>
				<a class="btn" href="#togglesound">Pause</a>

				<div class="controls-sep"></div>

				<a id="wiki-toggle-link" data-toggle-wiki="show" href="#wiki">i</a>
			</div>
		</div>

		<!-- Canvas wrap -->
		<div id="canvas-wrap"></div>

		<!-- Vendor scripts -->
		<script src="js/vendor/jquery-1.8.1.min.js"></script>
		<script src="js/vendor/instagram.js"></script>
		<script src="js/vendor/three.min.js"></script>
		<script src="js/vendor/three.orbitcontrols.js"></script>
		<script src="js/vendor/three.stats.js"></script>
		<script src="js/vendor/tween.min.js"></script>
		<script src="js/vendor/sprintf.min.js"></script>
		<script src="js/vendor/AudioContextMonkeyPatch.js"></script>

		<?php if ($isProduction) : ?>

		<!-- Data scripts -->
		<script defer src="js/audanism.js?v=20140717-1"></script>

		<?php else : ?>

		<!-- Utility functions -->
		<script defer src="js/src/utilities.js?v=<?php echo time(); ?>"></script>

		<!-- Audanism object initializer -->
		<script defer src="js/src/Audanism.js?v=<?php echo time(); ?>"></script>

		<!-- Global extensions -->
		<script defer src="js/src/Object.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Math.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Array.js?v=<?php echo time(); ?>"></script>

		<!-- Util -->
		<script defer src="js/src/TextInterpreter.js?v=<?php echo time(); ?>"></script>

		<!-- Event -->
		<script defer src="js/src/EventDispatcher.js?v=<?php echo time(); ?>"></script>

		<!-- Node -->
		<script defer src="js/src/Node.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/NodeCell.js?v=<?php echo time(); ?>"></script>
		
		<!-- Environment -->
		<script defer src="js/src/Organism.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Environment.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Interpreter.js?v=<?php echo time(); ?>"></script>

		<!-- Factor -->
		<script defer src="js/src/Factor.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/AgreeablenessFactor.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/ConscientiousnessFactor.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/ExtraversionFactor.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/NeuroticismFactor.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/OpennessFactor.js?v=<?php echo time(); ?>"></script>

		<!-- Calculator -->
		<script defer src="js/src/DisharmonyCalculator.js?v=<?php echo time(); ?>"></script>

		<!-- Source adapters -->
		<script defer src="js/src/SourceAdapter.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/RandomSourceAdapter.js?v=<?php echo time(); ?>"></script>
		<!-- <script defer src="js/src/TwitterSourceAdapter.js?v=<?php echo time(); ?>"></script> -->
		<script defer src="js/src/InstagramSourceAdapter.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/WheatherSourceAdapter.js?v=<?php echo time(); ?>"></script>

		<!-- Sound -->
		<script defer src="js/src/Harmonizer.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/ASDR.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Impulse.js?v=<?php echo time(); ?>"></script>
		
		<script defer src="js/src/FXChain.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/FX.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Reverb.js?v=<?php echo time(); ?>"></script>

		<script defer src="js/src/Instrument.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/TestInstrument.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Drone.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Pad.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/PercArpeggiator.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/NoisePink.js?v=<?php echo time(); ?>"></script>

		<script defer src="js/src/Voice.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Monoist.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/MonoistEnv.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/MonoistEnvMod.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/MonoistEnvModWide.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/MonoistEnvRev.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/MonoistEnvMulti.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/MonoistPerc.js?v=<?php echo time(); ?>"></script>
		<script defer src="js/src/Conductor.js?v=<?php echo time(); ?>"></script>

		<!-- GUI -->
		<script defer src="js/src/GUI.js?v=<?php echo time(); ?>"></script>

		<!-- Visual -->
		<script defer src="js/src/VisualOrganism.js?v=<?php echo time(); ?>"></script>

		<?php endif; ?>
	</body>
</html>
