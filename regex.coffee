## regex will be stored here
## Thanks Jim for the regex help!
## what should I put in the blacklist? hard to say...
whitelist = /my.*new\s*year.{0,2}\s*resolution|new\s*year.{0,2}\s\s*resolution.*my|new\s*year.{0,2}\s*resolution:/i
blacklist = /kill|die|murder|death|rape|suicide/i
module.exports = 
  whitelist: whitelist
  blacklist: blacklist