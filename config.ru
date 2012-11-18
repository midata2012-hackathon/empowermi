$LOAD_PATH.unshift(File.dirname(__FILE__))
require "rubygems"
require 'bundler/setup'
require './empowermi'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app/assets/javascripts'
  run environment
end

run Sinatra::Application
