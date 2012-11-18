require 'rubygems'
require 'sinatra'
require "sinatra/jsonp"
require 'json'
require 'pathname'
require 'sprockets'
require 'coffee-script'
require Pathname.getwd.join 'api_dump'

configure do
  set :sessions, true
  set :inline_templates, true
end

set :public_folder, 'public'

def asset_path(asset)
  "/assets/#{asset}"
end

get '/' do
  erb :index
end

get '/api/?:persona_id?' do |id|
  content_type :json
  id = id.to_s.to_sym
  id = MydexApi::CONFIG.keys[1..-1].include?(id) ? id : :rbfish
  jsonp ApiResponse::recommendations_for(id)
end
