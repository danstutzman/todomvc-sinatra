require 'rubygems'
require 'bundler'
Bundler.require

require 'logger'
require 'json'
require 'sinatra'

RACK_ENV = ENV['RACK_ENV'] || 'development'
Dotenv.load! ".env.#{RACK_ENV}"

$db = Sequel.connect(ENV.fetch('DATABASE_URL'))
$db.logger = Logger.new($stdout)

set :run, false # don't automatically start web server

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
      set :run, false
    end

    use Rack::Deflater

    get '/' do
      `rake app/concat`

      todo_json = TodoItem.all.to_json

      html = File.read('app/index.html')
      html.sub! /var initialTodos = \[\];/, "var initialTodos = #{todo_json};"
      html
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

    # just updates, not creates or deletes
    put '/todos' do
      hashes = JSON.parse(request.body.read)
      ids = TodoItem.select(:id).map { |todo| todo.id }
      hashes.each do |hash|
        todo = TodoItem.find(id: hash['id'])
        id = hash.delete('id')
        todo.update(hash)
      end
      'ok'
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
