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
        <title>Decision Making - Prototype 2 - Test 1</title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width">

        <!-- Place favicon.ico and apple-touch-icon.png in the root directory -->

        <link rel="stylesheet" href="css/normalize.css">
        <link rel="stylesheet" href="css/main.css">

        <?php if (!$runLocal) : ?>
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
        		<h1>Decision Making</h1>
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
        	</aside>

        	<menu id="controls">
        		<a class="btn" href="#start">Start</a>
        		<a class="btn" href="#pause">Pause</a>
        		<!-- <a class="btn" href="#stop">Stop</a> -->
        		<span style="float: left; margin-right: 10px; color: #999;">&middot;&middot;&middot;</span>
        		<a class="btn" href="#step">Step ></a>
        	</menu>
        </div>

        <!-- Scripts -->
        <!-- <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script> -->
        <script>window.jQuery || document.write('<script src="js/vendor/jquery-1.8.1.min.js"><\/script>')</script>

        <!-- Global extensions -->
        <script defer src="js/src/Object.js"></script>
        <script defer src="js/src/Math.js"></script>
        <script defer src="js/src/Array.js"></script>

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

		<!-- GUI -->
		<script defer src="js/src/GUI.js"></script>
    </body>
</html>