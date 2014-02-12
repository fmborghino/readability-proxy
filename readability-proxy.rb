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
  erb :index
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
  @parser_resp = http_get "https://readability.com/api/content/v1/parser?url=%s&token=%s" % [ params[:url], token ]
  dump_debug(@parser_resp) if debug?
  @parser_resp_body = JSON.parse(@parser_resp.body) rescue { error: true, message: "body not json: %s" % @parser_resp.body[0..50] }

  # normal error cases
  if @parser_resp.code != '200' or @parser_resp_body.has_key? :error
    @original_url = params[:url]
    @parser_resp_body['code'] = @parser_resp.code.to_i
    @parser_resp_body['url'] = @original_url
    if params[:format] == 'html'
      redirect to(@original_url) if on_error_redirect?
      content_type "text/html; charset=utf-8"
      return erb :parser_error
    else
      content_type "application/json"
      return [ @parser_resp.code.to_i, [ @parser_resp_body.to_json ] ]
    end
  end

  # unexpectedly borked responses occasionally show up, be defensive
  if (@parser_resp_body['content'].nil? or @parser_resp_body['content'].empty?) and
    params[:format] == 'html' and
    on_error_redirect?

    redirect to(params[:url])
  end

  if params[:format] == 'html'
    content_type "text/html; charset=utf-8"
    @title = clean_title @parser_resp_body['title'], params[:url]
    @proxied_content = true
    erb :content
  else
    content_type "application/json"
    @parser_resp.body
  end
end

def http_get url
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  request = Net::HTTP::Get.new(uri.request_uri)
  http.request(request)
end

def clean_title title, original_url
  if title.nil? or
    title.empty? or
    title == original_url

    '[Original article]'
  else
    title
  end
end

def on_error_redirect?
  !(params[:onerr].nil? or params[:onerr].empty?)
end

def debug?
  (!ENV['DEBUG'].nil?) || $config[:debug]
end

def dump_debug r
  puts "RESPONSE CODE %s" % r.code
  puts "HEADERS"
  r.each_header {|key,value| puts "#{key}: #{value}" }
  puts "BODY"
  puts r.body
end
