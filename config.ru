require 'rubygems'
require 'bundler'
Bundler.require

require './backend'
run Sinatra::Application
