ENV['RACK_ENV'] = 'test'
gem 'minitest'
require 'minitest/autorun'
require 'rack/test'
require './readability-proxy.rb'
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'boostrapping spec tests' do
  it 'should find and pass this test' do
    assert true
  end
end

describe 'rack test methods' do
  it 'should be working' do
    get '/'
    assert last_response.ok?
  end
end

describe "on error redirect" do
  it "should be on with the :onerr param" do
    get '/?onerr=1'
    assert on_error_redirect?
  end
end
