require 'json'
require 'net/http'
require 'uri'
require 'sinatra'

#$config = YAML.load_file(File.join(Dir.pwd, 'config.yml'))

configure do
end

before do
  headers "Content-Type" => "application/json"
end

get '/' do
  "Hello, world"
end

get '/parser' do
  headers "Content-Type" => "text/html; charset=utf-8"
  token = ENV['READABILITY_PARSER_TOKEN']
  url = "https://readability.com/api/content/v1/parser?url=%s&token=%s" % [ params[:url], token ]
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  response.each_header {|key,value| puts "#{key} = #{value}" }
  body = JSON.parse(response.body)
  puts response.body.inspect
  if body["error"]
    return "OOPS %s" % body["messages"]
  end
  "<p>(<b>%s</b>) %s</p><hr/>" % [response.code, body["title"]] + body["content"]
end
