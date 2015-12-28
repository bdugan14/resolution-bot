# resolution-bot
basic twitter bot

## general structure:
1) get tweets that match new years resolution
2) pass parameters into a callback that will post a response

## user logic flow, no external API
1) search NYR relevant tweets, set up a stream
2) if (user mentions resolution) search their profile for first NYE tweet from last year.
3) if no relevant tweet, do nothing
4) if relevant OLD tweet, and we haven't tweeted them, post reply to NEW tweet quoting their OLD tweet with random message, AKA "Before you do that, how did your last "
5) potential problems: search our OWN replies to make sure we don't tweet the same person twice, or store that person in a database. What if we exceed 3200 tweets? ahhh we fukd then. Could store people we responded to in a database (levelDB?);