source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base'
gem 'dotenv'

# Database
gem 'sequel'
gem 'sinatra-sequel'
gem 'pg'

group :development do
  gem 'bundler'
  gem 'rake'
  gem 'tugboat' # call Digital Ocean API from command-line
  gem 'zabbixapi' # call Zabbix API from Ruby
#  gem 'thin'
end

group :test do
  gem 'bundler'
  gem 'capybara', github: 'jnicklas/capybara', ref: '743a117' # support dblclick
  gem 'rspec'
  gem 'selenium-webdriver'
  gem 'rake'
  gem 'pry' # so I can stop capybara tests and debug them
  gem 'yarjuf' # JUnit RSpec formatter for Jenkins
  # having difficulty running thin on a custom port
end

group :production do
#  gem 'thin'
end
