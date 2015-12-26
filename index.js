//this is blatantly copy-pasted
var Twitter = require('twitter');
var config = require('./config.js');
 
var client = new Twitter({
  consumer_key: config.consumer_key,
  consumer_secret: config.consumer_secret,
  access_token_key: config.access_token_key,
  access_token_secret: config.access_token_secret
});
var params = {screen_name: 'yup_thats_words'};
client.get('statuses/user_timeline', params, function(error, tweets, response){
  if(error){
    console.log("had an error: ", error);
  }
  if (!error) {
    console.log("single tweet: ", tweets[2].text.slice(0,2));
    tweets.forEach(function(tweet, index){
      if(tweet.text.slice(0,2) !== "RT"){
        console.log("tweet number "+ index +": ",tweet.text);
      }
    })
    //console.log(tweets[0].text);
  }
});