require 'rubygems'
require 'sinatra'
require 'json'
require 'mongoid'
require 'dotenv'

Dotenv.load

Mongoid.load!('mongoid.yml')

configure do
  set :sessions, true
  set :inline_templates, true
end
  
get '/' do
  erb :index
end