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
  headers "Content-Type" => "text/html; charset=utf-8"
  [
    'try /parser?url=your_url for default json response',
    'try /parser?url=your_url&format=html to render the content'
  ].join('</br>')
end

get '/parser' do
  headers "Content-Type" => "text/html; charset=utf-8"
  token = ENV['READABILITY_PARSER_TOKEN'] || $config[:readability][:token]
  puts token
  url = "https://readability.com/api/content/v1/parser?url=%s&token=%s" % [ params[:url], token ]
  puts url
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  if $config[:debug]
    puts "RESPONSE CODE %s"%response.code
    puts "HEADERS"
    response.each_header {|key,value| puts "#{key}: #{value}" }
    puts "BODY"
    puts response.body
  end
  if response.code != "200"
    return "OOPS: code %s</br>%s" % [response.code, response.body]
  end
  body = JSON.parse(response.body)
  if body["error"]
    return "OOPS: %s" % body["messages"]
  end
  if params[:format] == 'html'
    headers "Content-Type" => "text/html; charset=utf-8"
    "<p>(<b>%s</b>) %s</p><hr/>" % [response.code, body["title"]] + body["content"]
  else
    headers "Content-Type" => "application/json"
    response.body
  end
end
