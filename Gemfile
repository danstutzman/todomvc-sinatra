source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base'
gem 'dotenv'

# Database
gem 'sequel'
gem 'sinatra-sequel'
gem 'pg'

gem 'bundler'
gem 'rake'

group :development do
  gem 'tugboat' # call Digital Ocean API from command-line
  gem 'zabbixapi' # call Zabbix API from Ruby
end

group :test do
  gem 'rspec'
  gem 'selenium-webdriver'
  gem 'pry' # so I can stop capybara tests and debug them
  gem 'yarjuf' # JUnit RSpec formatter for Jenkins
  gem 'capybara', github: 'jnicklas/capybara', ref: '743a117' # support dblclick
  gem 'database_cleaner'
  gem 'rack-test', require: 'rack/test'
end

group :production do
  gem 'thin'
end
