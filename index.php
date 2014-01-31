<?php

$runLocal = @$_GET['local'] == 'yes';

?><!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title>Audanism - Prototype 2 - Test 3</title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width">

        <link rel="shortcut icon" href="img/favicon.png">
        <link rel="stylesheet" href="css/normalize.css">
        <link rel="stylesheet" href="css/main.css">

        <?php if ($runLocal) : ?>
	        <script type="text/javascript" src="js/vendor/google.jsapi.js"></script>
	        <!-- <script type="text/javascript" src="js/vendor/google.visualization.js"></script> -->
	        <script type="text/javascript" src="js/vendor/google.charts.js"></script>
    	<?php else : ?>
	        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
			<script type="text/javascript">
			google.load("visualization", "1", {packages:["corechart"]});
			</script>
		<?php endif; ?>
    </head>
    <body>
        <!--[if lt IE 7]>
            <p class="chromeframe">You are using an outdated browser. <a href="http://browsehappy.com/">Upgrade your browser today</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to better experience this site.</p>
        <![endif]-->

        <div id="container">
        	<header id="header">
        		<h1>Audanism</h1>
        	</header>

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
        			<div class="value"></div>
        		</div>
        	</aside>

        	<menu id="controls">
        		<a class="btn" href="#start">Start</a>
        		<a class="btn" href="#pause">Pause</a>
        		<!-- <a class="btn" href="#stop">Stop</a> -->
        		<span style="float: left; margin-right: 10px; color: #999;">&middot;&middot;&middot;</span>
        		<a class="btn" href="#step">Step ></a>
        		<span style="float: left; margin-right: 10px; color: #999;">&middot;&middot;&middot;</span>
        		<input id="stressmode" type="checkbox" name="stressmode" />
        		<label for="stressmode">Stress mode</label>
        	</menu>
        </div>

        <!-- Vendor scripts -->
        <!-- <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script> -->
        <script>window.jQuery || document.write('<script src="js/vendor/jquery-1.8.1.min.js"><\/script>')</script>
        <script defer src="js/vendor/instagram.js"></script>
        <script defer src="js/vendor/Audiolet.min.js"></script>

        <!-- Audanism object initializer -->
        <script defer src="js/src/Audanism.js"></script>

        <!-- Global extensions -->
        <script defer src="js/src/Object.js"></script>
        <script defer src="js/src/Math.js"></script>
        <script defer src="js/src/Array.js"></script>

        <!-- Util -->
        <script defer src="js/src/TextInterpreter.js"></script>

		<!-- Node -->
		<script defer src="js/src/Node.js"></script>
		<script defer src="js/src/NodeCell.js"></script>
		
        <!-- Environment -->
		<script defer src="js/src/Organism.js"></script>
		<script defer src="js/src/Environment.js"></script>
		<script defer src="js/src/Interpreter.js"></script>

        <!-- Factor -->
		<script defer src="js/src/Factor.js"></script>
        <script defer src="js/src/AgreeablenessFactor.js"></script>
		<script defer src="js/src/ConscientiousnessFactor.js"></script>
		<script defer src="js/src/ExtraversionFactor.js"></script>
		<script defer src="js/src/NeuroticismFactor.js"></script>
		<script defer src="js/src/OpennessFactor.js"></script>

		<!-- Calculator -->
		<script defer src="js/src/DisharmonyCalculator.js"></script>
		<!-- <script defer src="js/src/OrganismDisharmonyCalculator.js"></script> -->
		<!-- <script defer src="js/src/FactorComparer.js"></script> -->
		<!-- <script defer src="js/src/NodeComparer.js"></script> -->

		<!-- Source adapters -->
		<script defer src="js/src/SourceAdapter.js"></script>
		<script defer src="js/src/RandomSourceAdapter.js"></script>
		<!-- <script defer src="js/src/TwitterSourceAdapter.js"></script> -->
		<script defer src="js/src/InstagramSourceAdapter.js"></script>

		<!-- Sound -->
		<script defer src="js/src/Conductor.js"></script>
		<script defer src="js/src/Noise.js"></script>
		<script defer src="js/src/Synth.js"></script>
		<script defer src="js/src/Synth2.js"></script>
		<script defer src="js/src/Blip.js"></script>
		<script defer src="src/sound/instrument/NodeInfluenceSound1.js"></script>
		<script defer src="src/sound/instrument/NodeInfluenceSound2.js"></script>
		<script defer src="src/sound/instrument/NodeComparisonSound1.js"></script>

		<!-- GUI -->
		<script defer src="js/src/GUI.js"></script>
    </body>
</html>
