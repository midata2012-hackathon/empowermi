require 'rubygems'
require 'sinatra'
require 'json'
require 'mongoid'
# require 'dotenv'
# 
# Dotenv.load
# 
Mongoid.load!('mongoid.yml')

configure do
  set :sessions, true
  set :inline_templates, true
end

set :public_folder, 'public'

get '/' do
  redirect '/index.html'
  # erb :index
end