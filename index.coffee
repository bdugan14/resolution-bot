## this is where we require dependencies in node.
## the first one, Twitter is a third-party library that
## handles interaction with the twitter api. It's capitalized because it's a constructor.
## The second is our config file, and the ./ signifies it's in the same folder
## as our index.js
Twitter = require "twitter"
config = require "./config.js"

client = new Twitter
  consumer_key: config.consumer_key
  consumer_secret: config.consumer_secret
  access_token_key: config.access_token_key
  access_token_secret: config.access_token_secret
ourParams = 
  track: 'javascript'
createFilterStream = (params) ->
  client.stream 'statuses/filter', params, (stream) ->
    stream.on 'data', (tweet)->
      console.log tweet.text
    stream.on 'error', (error)->
      throw error
createFilterStream ourParams