config = require('./config.js')
db = require('monk')(config.mongolabsURI);
tweets = db.get('tweets')

module.exports =
  addTweet: (tweetId) ->
    tweets.insert(tweet_id: tweetId)
  fetchTweets: ->
    tweets.find({})
