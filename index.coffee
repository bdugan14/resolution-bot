## this is where we require dependencies in node.
## the first one, Twitter is a third-party library that
## handles interaction with the twitter api. It's capitalized because it's a constructor.
## The second is our config file, and the ./ signifies it's in the same folder
## as our index.js
Twitter = require "twitter"
config = require "./config.js"
regex = require "./regex.js"
db = require "./db.js"
testTweets = require './testTweets.js'
responses = require './responses.js'
q = require 'q'

client = new Twitter
  consumer_key: config.consumer_key
  consumer_secret: config.consumer_secret
  access_token_key: config.access_token_key
  access_token_secret: config.access_token_secret
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
  ".@#{username} #{responses.responses[Math.floor(Math.random()*responses.responses.length)]}"

postTweet = (tweetId, status) ->
  console.log "postingTweet...", tweetId, status
  _params =
    status: status
    in_reply_to_status_id: tweetId
  client.post('statuses/update', _params, (error, tweet, response) ->
    console.log "got response..."
    if(error) then throw error
    console.log "tweet: ", tweet
    console.log "response", response
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
  console.log "_csvTweets: ", _csvTweets
  client.get('statuses/lookup', {id: _csvTweets, include_entities: false}, (error, tweets, response) ->
    console.log "got response..."
#    console.log "error[0].code: ", typeof error[0].code
    # if error[0].code is 144 then
    if(error) then console.log "error: ", error[0].code
    _parsedTweets = tweets.map (tweet) ->
      console.log 'tweet: ', tweet
      _importantInfo =
        id_str: tweet.id_str
        screen_name: tweet.user.screen_name
#    console.log "tweets: ", tweets
    defer.resolve _parsedTweets
    console.log "parsed tweets: ", _parsedTweets
#    console.log "response", response.body
  )
  defer.promise


fetchTweetsFromDb = ->
  console.log 'calling fetchTweetsFromDb!'
  return db.fetchTweets().then (tweets) ->
    console.log 'tweets: ', tweets
    console.log 'all args:', arguments.length
    tweets.map (dbObj) ->
      dbObj.tweet_id


isTweetGood = (tweet) ->
  if not tweet.text then return console.log tweet
  if tweet.text.slice(0,2) is "RT" then return false
  if regex.blacklist.test(tweet.text) is true then return false
  if regex.whitelist.test(tweet.text) is false then return false
  if tweet.user.followers_count < 500 then return false
  ##this doesn't check anything about the user yet
  true
# comment this out to get the stream, but we're not really about that now
#createFilterStream ourParams

#postTweet '711268538271424512', '@AndyOnTheWeeknd lala fake tweet'
#getTweet '711268538271424512'
#getManyTweets testTweets.tweetList
#fetchTweetsFromDb().then (tweets) ->
#  console.log 'tweets: ', tweets
#  _first100 = tweets.slice 0, 100
#  getManyTweets(_first100)
#  .then (tweets) ->
#    console.log 'in thingy'
#    _tweets = tweets.map (tweetObj) ->
#      id: tweetObj.id_str
#      status: generateTweet(tweetObj.screen_name)
#    console.log 'tweets: ', _tweets




#  console.log 'first 100', _first100
#  console.log 'first 100 length: ', _first100.length
#
#
#getManyTweets(['795848031958495232','798010102556958721', '712362150145077248'])
#.then (tweets) ->
#  tweets.map (tweet) ->
#    console.log 'tweet:', tweets
#    postTweet(tweet.id_str, generateTweet(tweet.screen_name))
postTweet '798010102556958721', generateTweet('andyontheweeknd')


