<?php

$runLocal = @$_GET['local'] == 'yes';

$isProduction = preg_match("/\.com/", $_SERVER['HTTP_HOST']);

?><!DOCTYPE html>
<!--[if lt IE 7]>	  <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>		 <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>		 <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js canvas-only"> <!--<![endif]-->
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<title>Audanism - Prototype 2 - Test 3</title>
		<meta name="description" content="">
		<meta name="viewport" content="width=device-width">

		<link rel="shortcut icon" href="img/favicon.png">
		<!-- <link href='http://fonts.googleapis.com/css?family=Open+Sans:400,300,700' rel='stylesheet' type='text/css'> -->
		<!-- <link href='http://fonts.googleapis.com/css?family=Dosis:300,400,700' rel='stylesheet' type='text/css'> -->
		<link rel="stylesheet" href="css/normalize.css">
		<link rel="stylesheet" href="css/main.css">

		<?php /* if ($runLocal) : ?>
			<script type="text/javascript" src="js/vendor/google.jsapi.js?v=<?php echo time(); ?>"></script>
			<!-- <script type="text/javascript" src="js/vendor/google.visualization.js?v=<?php echo time(); ?>"></script> -->
			<script type="text/javascript" src="js/vendor/google.charts.js?v=<?php echo time(); ?>"></script>
		<?php else : ?>
			<script type="text/javascript" src="https://www.google.com/jsapi"></script>
			<script type="text/javascript">
			google.load("visualization", "1", {packages:["corechart"]});
			</script>
		<?php endif; */ ?>
	</head>
	<body>
		<!--[if lt IE 7]>
			<p class="chromeframe">You are using an outdated browser. <a href="http://browsehappy.com/">Upgrade your browser today</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to better experience this site.</p>
		<![endif]-->

		<div id="container">
			<header id="header">
				<h1>Audanism</h1>
			</header>

			<?php /*
			<div id="main">
				<h3>Factors</h3>
				<div id="factors" class="clearfix block"></div>

				<h3>Nodes</h3>
				<div id="nodes" class="clearfix block"></div>
			</div>

			<aside id="meta">
				<p id="organism-state"></p>

				<div id="disharmony-chart"></div>

				<div id="disharmony-meter">
					<div class="meter"></div>
					<div class="value">
						<span class="sum"></span>
						<span class="actual"></span>
					</div>
				</div>
			</aside>
			*/ ?>

			<aside id="stats-wrap">
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
									<div class="stress-mode-indicator"></div>
								</th>
							</tr>
						</thead>

						<tbody class="stats-block-content">
							<tr id="summed-disharmony">
								<td class="label" title="Summed organism disharmony">SUM</td>
								<td class="value">12381</td>
							</tr>

							<tr id="actual-disharmony">
								<td class="label" title="Real organism disharmony, depending on state">REAL</td>
								<td class="value">12381</td>
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
								<td class="label">F</td>
								<td class="value" data-factor="1">10</td>
								<td class="value" data-factor="2">23</td>
								<td class="value" data-factor="3">23</td>
								<td class="value" data-factor="4">23</td>
								<td class="value" data-factor="5">23</td>
							</tr>

							<tr id="factor-disharmonies">
								<td class="label">FD</td>
								<td class="value" data-factor="1">34k</td>
								<td class="value" data-factor="2">12k</td>
								<td class="value" data-factor="3">1m</td>
								<td class="value" data-factor="4">499</td>
								<td class="value" data-factor="5">1k</td>
							</tr>
						</tbody>
					</table>
				</div>

				<!-- Influences -->
				<div id="influences" class="stats-block">
					<div class="stats-title">Influences</div>

					<div class="stats-block-content">
						<div class="influence template">
							<div class="influence-type">Node</div>
							<div class="influence-source stats-label">Instagram</div>
							<div class="influence-summary">A summary that will be shortened</div>
							<div class="influence-link"><a href="#">Link</a></div>
							<div class="influence-value">5.5</div>
						</div>
					</div>
				</div>
			</aside>

			<div id="controls">
				<a class="btn" href="#start">Start</a>
				<a class="btn" href="#pause">Pause</a>
				<!-- <a class="btn" href="#stop">Stop</a> -->
				<!-- <span style="float: left; margin-right: 10px; color: #999;">&middot;&middot;&middot;</span> -->
				<a class="btn" href="#step">Step ></a>
				<!-- <span style="float: left; margin-right: 10px; color: #999;">&middot;&middot;&middot;</span> -->
				<!-- <input id="stressmode" type="checkbox" name="stressmode" /> -->
				<!-- <label for="stressmode">Stress mode</label> -->
			</div>
		</div>

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
		<script defer src="js/audanism.js?v=20140305-2"></script>

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
		<!-- <script defer src="js/src/OrganismDisharmonyCalculator.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="js/src/FactorComparer.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="js/src/NodeComparer.js?v=<?php echo time(); ?>"></script> -->

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
		<!-- <script defer src="js/src/Noise.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="js/src/Synth.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="js/src/Synth2.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="js/src/Blip.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="src/sound/instrument/NodeInfluenceSound1.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="src/sound/instrument/NodeInfluenceSound2.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="src/sound/instrument/NodeComparisonSound1.js?v=<?php echo time(); ?>"></script> -->
		<!-- <script defer src="src/sound/instrument/InfluenceActionSound1.js?v=<?php echo time(); ?>"></script> -->

		<!-- GUI -->
		<script defer src="js/src/GUI.js?v=<?php echo time(); ?>"></script>

		<!-- Visual -->
		<script defer src="js/src/VisualOrganism.js?v=<?php echo time(); ?>"></script>

		<?php endif; ?>
	</body>
</html>
