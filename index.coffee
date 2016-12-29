## this is where we require dependencies in node.
## the first one, Twitter is a third-party library that
## handles interaction with the twitter api. It's capitalized because it's a constructor.
## The second is our config file, and the ./ signifies it's in the same folder
## as our index.coffee
require('dotenv').config()
Twitter = require "twitter"
R = require 'ramda'
regex = require "./regex.coffee"
db = require "./db.coffee"
testTweets = require './testTweets.coffee'
responses = require './responses.coffee'
q = require 'q'

twitterApiTime = 36000

client = new Twitter
  consumer_key: process.env.CONSUMER_KEY
  consumer_secret: process.env.CONSUMER_SECRET
  access_token_key: process.env.ACCESS_TOKEN_KEY
  access_token_secret: process.env.ACCESS_TOKEN_SECRET
ourParams =
  track: '#newyearsresolution, new years resolution'
createFilterStream = (params) ->
  client.stream 'statuses/filter', params, (stream) ->
    stream.on 'data', (tweet)->
      if isTweetGood tweet 
        console.log tweet.text, tweet.id_str 
        db.addTweet tweet.id_str
    stream.on 'error', (error)->
      throw error
## this is where we should do all the the filtering

generateTweet = (username) ->
  rawtweet="#{responses.responses[Math.floor(Math.random()*responses.responses.length)]}"
  rawtweet.replace('{handle}', "@#{username}")

postTweet = (tweetId, status) ->
  console.log "postingTweet...", tweetId, status
  _params =
    status: status
    in_reply_to_status_id: tweetId
    # uncomment when live
  client.post('statuses/update', _params, (error, tweet, response) ->
    console.log "got response..."
    if(error) then throw error
#    console.log "tweet: ", tweet
    console.log "response from post"
  )

getTweet = (tweetId) ->
  client.get('statuses/show/', {id: tweetId}, (error, tweet, response) ->
    console.log "got response..."
    console.log "error[0].code: ", typeof error[0].code
    # if error[0].code is 144 then
    if(error) then console.log "error: ", error[0].code
    console.log "tweet: ", tweet
    console.log "response", response.body
  )

getManyTweets = (tweets) ->
  defer = q.defer()
  _csvTweets = tweets.join ','
  client.get('statuses/lookup', {id: _csvTweets, include_entities: false}, (error, tweets, response) ->
    console.log "got response..."
#    console.log "error[0].code: ", typeof error[0].code
    # if error[0].code is 144 then
    if(error) then console.log "error: ", error[0].code
    _parsedTweets = tweets.map (tweet) ->
      _importantInfo =
        id_str: tweet.id_str
        screen_name: tweet.user.screen_name
#    console.log "tweets: ", tweets
    defer.resolve _parsedTweets
#    console.log "response", response.body
  )
  defer.promise

#Takes an array of tweets, and index, and a defer
_recurseThroughTweets = (tweets, n, defer) ->
  _tweet = tweets[n]
  postTweet _tweet.id, _tweet.status
  if n is (tweets.length - 1)
    return defer.resolve true
  setTimeout ->
    _recurseThroughTweets tweets, n+1, defer
  , twitterApiTime


_handleTweets = (tweets) ->
  defer = q.defer()
  _recurseThroughTweets tweets, 0, defer
  defer.promise


fetchTweetsFromDb = ->
  console.log 'calling fetchTweetsFromDb!'
  return db.fetchTweets().then (tweets) ->
    console.log 'all args:', arguments.length
    tweets.map (dbObj) ->
      dbObj.tweet_id


isTweetGood = (tweet) ->
  if not tweet.text then return console.log tweet
  if tweet.text.slice(0,2) is "RT" then return false
  if regex.blacklist.test(tweet.text) is true then return false
  if regex.whitelist.test(tweet.text) is false then return false
  #TODO: fix this
  if tweet.user.followers_count < 500 then return false
  ##this doesn't check anything about the user yet
  true
# comment this out to get the stream, but we're not really about that now
#createFilterStream ourParams

#postTweet '711268538271424512', '@AndyOnTheWeeknd lala fake tweet'
#getTweet '711268538271424512'
#getManyTweets testTweets.tweetList

fetchTweetsFromDb().then (tweets) ->
  console.log 'tweets: ', tweets.length
  # TODO: get this to do more than 100 tweets
  n = 0
  _hundredRawTweetChunk = tweets.slice n, (n+100)
  console.log 'hundredRawTweetChung: ', _hundredRawTweetChunk.length
  getManyTweets(_hundredRawTweetChunk)
  .then (tweets) ->
    console.log 'in thingy'
    _tweets = tweets.map (tweetObj) ->
      id: tweetObj.id_str
      status: generateTweet(tweetObj.screen_name)
    _tweets
  .then _handleTweets
  .then (done) ->
    console.log 'done!', done

#  console.log 'first 100', _hundredRawTweetChunk
#  console.log 'first 100 length: ', _hundredRawTweetChunk.length
#
#
#getManyTweets(['795848031958495232','798010102556958721', '712362150145077248'])
#.then (tweets) ->
#  tweets.map (tweet) ->
#    console.log 'tweet:', tweets
#    postTweet(tweet.id_str, generateTweet(tweet.screen_name))
#postTweet '798010102556958721', generateTweet('andyontheweeknd')


