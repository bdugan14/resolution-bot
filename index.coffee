## this is where we require dependencies in node.
## the first one, Twitter is a third-party library that
## handles interaction with the twitter api. It's capitalized because it's a constructor.
## The second is our config file, and the ./ signifies it's in the same folder
## as our index.js
Twitter = require "twitter"
config = require "./config.js"
regex = require "./regex.js"

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
      if isTweetGood tweet then console.log tweet.text, tweet.id_str
    stream.on 'error', (error)->
      throw error
## this is where we should do all the the filtering
isTweetGood = (tweet) ->
  if tweet.text.slice(0,2) is "RT" then return false
  if regex.blacklist.test(tweet.text) is true then return false
  if regex.whitelist.test(tweet.text) is false then return false
  ##this doesn't check anything about the user yet
  true
createFilterStream ourParams
saveTweet = (tweet) ->

