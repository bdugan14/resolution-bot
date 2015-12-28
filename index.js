//this is blatantly copy-pasted
var Twitter = require('twitter');
var config = require('./config.js');
var math = require('mathjs');
 
var client = new Twitter({
  consumer_key: config.consumer_key,
  consumer_secret: config.consumer_secret,
  access_token_key: config.access_token_key,
  access_token_secret: config.access_token_secret
});
var tweetBatch = [];
var harassDavid = function(){
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
      });
      //console.log(tweets[0].text);
    }
  });
};


//this section actually calls the searchTweets function
// var newParams = {q: "new years resolution"};
// searchTweets(newParams);
var postReply = function(params){
  client.post('statuses/update', params, function(error, tweets, response){
    if(error){
      console.log("had an error: ", error);
    }
    if (!error) {
      console.log("We posted it!");
      //console.log(tweets[0].text);
    }
  });
};
function isWorthSearch(user){
  if(user.followers_count < 100){
    console.log("Didn't search. user not popular enough! followers: ", user.followers_count);
    return false;
  }
  //date refers to midnight, jan 1st, last year
  if(Date.parse(user.created_at) > 1419753600000){
    console.log("Didn't search. user hasn't been on twitter long enough! date: ", user.created_at);
    return false;
  }
  return true;
}
var checkForNYR = function(tweet, callback){
  var idStr = tweet.user.id_str;
  console.log("checkForNYR id ", idStr);
  var userIds = tweetBatch.map(function(tweet, index){
    return tweet.user.id_str;
  }).join(",");
  console.log("clearing tweet batch!");
  var cachedBatch = tweetBatch;
  tweetBatch = [];
  console.log("cachedBatch now: ", cachedBatch.length);
  client.get('users/lookup', ({user_id: userIds}), function(error, users, response){
    if(error){
      console.log("error in checkForNYR: ", error);
    } else {
      users.forEach(function(user, index){
        //the callback will post a response
        if(isWorthSearch(user)){

          binarySearch(cachedBatch[index], user, function(tweet, user){
            console.log("holy shit found it! tweet and user: ", tweet.text, user.id_str);
          });
        } else {
          console.log("he wasn't popular enough. followers: ", user.followers_count);
        }
      });
      //var cachedBatch = null;
    }
  });
  //lookup user, see their relevance under followers_count

};
var binarySearch = function(newTweet, user, callback){
  // if(newTweet.user.id_str !== user.id_str){
  //   console.log("ERROR! id's don't match");
  // }
  var bigNumIdLessOne = math.subtract(math.bignumber(newTweet.id_str), 1).toString(); 
  var initParams = {
    user_id: user.id_str,
    trim_user: true,
    exclude_replies: true,
    include_rts: false,
    max_id: bigNumIdLessOne
  };
  //hardcoded to Andy
  //improve this later
  var re = /new years resolution/i;
  function innerFunc(params){
    //console.log("consider it called");
    client.get('statuses/user_timeline', params, function(error, tweets, response){
      var continueSearch = true;
      var lowestId = math.bignumber(params.max_id);
      //console.log("heard back from twitter! max_id: ", lowestId.toString());
      if(!(Array.isArray(tweets))){
        console.log("twitter maaaad", tweets.errors);
        return;
      }
      tweets.forEach(function(tweet){
        var date = Date.parse(tweet.created_at);
        if(continueSearch && Date.parse(tweet.created_at) < 1419753600000){
          console.log("uh oh! too old ᶘᵒᴥᵒᶅ");
          console.log("currentId: ",tweet.id_str);
          continueSearch = false;
        }
        if(continueSearch && re.exec(tweet.text) && date < 1420444800000){
          console.log("holy shit matched the regex! text: ", tweet.text);
          continueSearch = false;
          //return callback(newTweet, oldTweet, user);
          return callback();
        }
        var currentId = math.bignumber(tweet.id_str);
        if(parseInt(math.subtract(lowestId, currentId).toString())>0){
          lowestId = currentId;
        }
      });
      if(continueSearch){
        params.max_id = lowestId.toString();
        //console.log("callin it again! with lowestId: ", params.max_id);
        innerFunc(params);
      }
    });
  }
  innerFunc(initParams);
};

var respondTo = function(newTweet, oldTweet, user){

};
var createFilterStream = function(params){
  client.stream('statuses/filter', params, function(stream) {
    stream.on('data', function(tweet) {
      if(tweet.text.slice(0,2) !== "RT"){
          console.log("non-RT found!", tweet.text);
          //dunno if this works?
          console.log("checking history for user ", tweet.user.id_str);
          tweetBatch.push(tweet);
          console.log("batch length: ", tweetBatch.length);
          if(tweetBatch.length === 3){
            checkForNYR(tweet, function(error, oldResolutionTweet){
              if(!error){
                console.log("found tweet!");
              }
            });
          }
        }
      //check our tweets to see if we've tweeted them, then
      //*DO THIS NOW*check their tweets from last year to see if any match, then
      //view matching
      //console.log("data found!");
      //console.log(tweet.text);
    });
   
    stream.on('error', function(error) {
      throw error;
    });
  });
};
//THIS IS WHERE I SHOULD CALL FILTERSTREAM
createFilterStream({track:"#newyearsresolution"});
// var replyParams = {
//   status: ".@andyontheweeknd Great Tweet! Keep it up!",
//   in_reply_to_status_id: "659941196467322881"
// };
//postReply(replyParams);

// binarySearch(null, null, function(){
//   console.log("holy shit we did it fam");
// });