db = require('monk')(process.env.MONGOLABS_URI);
tweets = db.get('tweets')

module.exports =
  addTweet: (tweetId) ->
    tweets.insert(tweet_id: tweetId)
  fetchTweets: ->
    tweets.find({})
