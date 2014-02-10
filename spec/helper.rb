ENV['RACK_ENV'] ||= 'test'

require 'rubygems'
require 'bundler'
require 'pry'

Bundler.setup :default, :test

require 'rspec'
require 'capybara/rspec'
require 'selenium-webdriver' # just to access Selenium constant

if ENV['REMOTE'] == 'true'
  # See https://saucelabs.com/docs/additional-config
  # See https://saucelabs.com/platforms
  caps = Selenium::WebDriver::Remote::Capabilities.new
  caps[:browserName] = ENV['SELENIUM_BROWSER'] or raise \
    'ENV[SELENIUM_BROWSER] should be firefox, internet explorer, etc.'
  caps[:platform]    = ENV['SELENIUM_PLATFORM'] or raise \
    'ENV[SELENIUM_PLATFORM] should be mac, windows, Windows XP, ANY, etc.'
  caps[:version]     = ENV['SELENIUM_VERSION'] # blank, 6
  caps[:javascript_enabled] = true # so we don't get non-js htmlunit driver
  caps[:username]    = ENV['SAUCE_USER_NAME']
  caps[:accessKey]   = ENV['SAUCE_API_KEY']
  caps[:name]        = ARGV[0]
  selenium_host = ENV['SELENIUM_HOST'] or raise "No ENV[SELENIUM_HOST]"
  selenium_port = ENV['SELENIUM_PORT'] or raise "No ENV[SELENIUM_PORT]"
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new app,
      browser: :remote,
      url: "http://#{selenium_host}:#{selenium_port}/wd/hub",
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
set :run, false # don't automatically start sinatra server
require './backend'
Capybara.run_server = true
Capybara.app_host = 'http://0.0.0.0:3000'
Capybara.server_port = 3000
Capybara.app = TodomvcBackend::App.new
Capybara.server do |app, port| # Run web server from 0.0.0.0 so vms can see it
  require 'rack/handler/webrick'
  Rack::Handler::WEBrick.run app,
    Host: '0.0.0.0',
    Port: port,
    #AccessLog: [],
    Logger: WEBrick::Log::new($stdout)
end
