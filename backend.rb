require 'rubygems'
require 'bundler'
Bundler.require

require 'logger'
require 'json'

RACK_ENV = ENV['RACK_ENV'] || 'development'
Dotenv.load! ".env.#{RACK_ENV}"

$db = Sequel.connect(ENV.fetch('DATABASE_URL'))
$db.logger = Logger.new($stdout)

module TodomvcBackend
  class TodoItem < Sequel::Model
    plugin :json_serializer
  end

  class App < Sinatra::Application
    configure do
      disable :method_override
      set :sessions,
          httponly:     true,
          secure:       production?,
          expire_after: 60 * 60 * 24 * 365,
          secret:       ENV['SESSION_SECRET']
    end

    use Rack::Deflater

    get '/' do
      `rake app/concat`
      send_file 'app/index.html'
    end

    get '/todos' do
      TodoItem.all.to_json
    end

    post '/todos' do
      hash = JSON.parse(request.body.read)
      id = hash.delete('id')
      todo = TodoItem.new(hash)
      todo.save
      todo.to_json
    end

    put '/todos/:id' do
      todo = TodoItem[params[:id]]
      hash = JSON.parse(request.body.read)
      id = hash.delete('id')
      todo.update(hash)
      todo.to_json
    end

    delete '/todos/:id' do
      todo = TodoItem[params[:id]]
      todo.destroy
      'OK'
    end

    get '/learn.json' do
      '[]'
    end
  end
end

#configure(:test) { disable :logging }
