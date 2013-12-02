Simple Readability.com Parser API proxy

What we have here: Sinatra, rack, shotgun, haml, sass, heroku

Dev mode usage: shotgun
Or: rackup config.ru

Production deploy: git push heroku master
Production mode usage: heroku open
(or visit: http://sinatra-readability-proxy.herokuapp.com/)

Secret: Preferably set this with
  heroku config:set READABILITY_PARSER_TOKEN=your_token
Else set in config.yml. Recommend you don't check this in.
