require 'rubygems'
require 'sinatra'
require "sinatra/jsonp"
require 'json'
require 'pathname'

configure do
  set :sessions, true
  set :inline_templates, true
end

set :public_folder, 'public'

get '/' do
  redirect '/index.html'
end

get '/api' do
  # change this to serve the generated json when we have the right logic
    content_type :json
    File.read(Pathname.getwd.join('docs', 'api.json'))
end