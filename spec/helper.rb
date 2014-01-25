ENV['RACK_ENV'] ||= 'test'

require 'rubygems'
require 'bundler'
require 'pry'

Bundler.setup :default, :test

require 'rspec'
require 'capybara/rspec'
require 'selenium-webdriver' # just to access Selenium constant

if ENV['REMOTE'] == 'true'
  browser = :internet_explorer
  caps = Selenium::WebDriver::Remote::Capabilities.send(browser)
  caps[:javascript_enabled] = true # so we don't get non-js htmlunit driver
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new app,
      browser: :remote,
      url: 'http://localhost:4444/wd/hub',
      desired_capabilities: caps
  end
else
  browser = :firefox
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new app, browser: browser
  end
end
Capybara.javascript_driver = :selenium
Capybara.default_driver = :selenium

require 'sinatra'
require './backend'
Capybara.run_server = true
Capybara.app_host = 'http://0.0.0.0:3000'
Capybara.server_port = 3000
Capybara.app = Sinatra::Application
Capybara.server do |app, port| # Run web server from 0.0.0.0 so vms can see it
  require 'rack/handler/webrick'
  Rack::Handler::WEBrick.run(app, :Host => '0.0.0.0', :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(nil, 0))
end
