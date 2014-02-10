# Simple Readability.com Parser API Proxy

## What we have here
- Implementation: Sinatra, rack, rerun, heroku
- Single page web UI to experiment with the proxy

## API Token
Get a token from https://www.readability.com/developers/api/parser

Preferably set this with

    heroku config:set READABILITY_PARSER_TOKEN=your_token

Else set in config.yml. Recommend you don't check this in.

## Dev mode usage

    READABILITY_PARSER_TOKEN=your_token rerun rackup

Or set the token in the config.yml.

## Production deploy
    git push heroku master

## Production mode usage
    heroku open

Or visit http://your-app-name.herokuapp.com

## API
The parse proxy API is at

   http://your-app-name.herokuapp.com/v1/parser

You can POST or GET against this endpoint.

### Parameters

* `url` The url for which you want content.
  
  This is the url for which you want Readability's parser API response.

* `format` The response format you expect, [json|html]. Defaults to json.
  * json format will return the entire raw json response from the Readability parser API.  
  * html format will inject some css and return a valid html5 page with
  the content section of the parser API response. A header is added with
  the article title that is also a link to the original url.

* `onerr` Whether to redirect on error, [true|false]. Defaults to false.

  When set to true, any error from the parser API will respond with a
  redirect to the original url. This is useful if your client is loading
  the html format into a webview, for example. On Android for example this
  will cause the external browser to launch with the original url.

  This param has no effect in json format responses. Those already
  contain a json representation of the error. 

### Errors from the parser
There are various reasons the Readability parser API cannot return
resonable content. If you are not using the onerr param then you will
see the error rendered with json or html. The onerr param is a quick
cheat to convert any error into a redirect to the original url.


