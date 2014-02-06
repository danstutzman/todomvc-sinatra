require 'rubygems'
require 'bundler'
Bundler.require
RACK_ENV = ENV['RACK_ENV'] || 'development'
Dotenv.load! ".env.#{RACK_ENV}"

module TodomvcBackend
  class App < Sinatra::Application
    configure do
      disable :method_override
      disable :static

      set :sessions,
          httponly:     true,
          secure:       production?,
          expire_after: 60 * 60 * 24 * 365,
          secret:       ENV['SESSION_SECRET']
    end

    use Rack::Deflater

    get '/' do
      'here'
    end
  end
end

#configure(:test) { disable :logging }
