###
	Listens for tweets.
###
class TwitterSourceAdapter extends SourceAdapter

	# Constructor
	constructor: (@listener) ->
		super(@listener)

		@tweetSinceId = 0

		@queries = ["#belieber"]
		@queryUrl = "http://search.twitter.com/search.json?q=#{ decodeURIComponent(@queries.join(',')) }&since_id=#{ @tweetSinceId }&result_type=recent"

	# Sets up mouse event listeners
	activate: () ->
		console.log('TSA activate')
		@queryTweets()

	# Performs a query for tweets
	queryTweets: () ->
		console.log('query tweets', @queryUrl)


	# Adapts the mouse data into environment interpretable data
	adaptSourceData: () ->


window.TwitterSourceAdapter = TwitterSourceAdapter 