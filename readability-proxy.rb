require 'yaml'
require 'json'
require 'net/http'
require 'uri'
require 'sinatra'

$config = YAML.load_file(File.join(Dir.pwd, 'config.yml'))

configure do
end

before do
end

get '/' do
  content_type 'text/html; charset=utf-8'
  haml :index
end

post '/v1/parser.?:format?' do
  parser
end

get '/v1/parser.?:format?' do
  parser
end

private

def parser
  token = ENV['READABILITY_PARSER_TOKEN'] || $config[:readability][:token]
  response = http_get "https://readability.com/api/content/v1/parser?url=%s&token=%s" % [ params[:url], token ]
  if debug?
    puts "RESPONSE CODE %s"%response.code
    puts "HEADERS"
    response.each_header {|key,value| puts "#{key}: #{value}" }
    puts "BODY"
    puts response.body
  end
  body = JSON.parse(response.body) rescue { error: true, message: "body not json: %s" % response.body[0..50] }
  if response.code != "200" or body.has_key? :error
    body['code'] = response.code.to_i
    if params[:format] == 'html'
      content_type "text/html; charset=utf-8"
      return haml :parser_error, locals: { response: response, body: body }
    else
      content_type "application/json"
      return [ response.code.to_i, [ body.to_json ] ]
    end
  end

  if params[:format] == 'html'
    content_type "text/html; charset=utf-8"
    "<p><a href=\"%s\"><b>%s</b></a></p><hr/>" % [body['url'], body['title']] + body['content']
  else
    content_type "application/json"
    response.body
  end
end

def http_get url
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  http.request(request)
end

def debug?
  (not ENV['DEBUG'].nil?) || $config[:debug]
end
