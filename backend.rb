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

    get '/todos.json' do
      TodoItem.all.to_json
    end

    put '/todos.json' do
      hashes = JSON.parse(request['todos'])
      ids = TodoItem.select(:id).map { |todo| todo.id }
      ids_to_delete = Set.new(ids)
      hashes.each do |hash|
        todo = TodoItem.find(id: hash['id'])
        ids_to_delete.delete hash['id']
        if todo.nil?
          todo = TodoItem.new
          todo.id = hash['id']
        end
        todo.title = hash['title']
        todo.completed = hash['completed']
        todo.save
      end
      ids_to_delete.each do |id|
        TodoItem.find(id: id).delete
      end
      'OK'
    end

    get '/learn.json' do
      '[]'
    end
  end
end

#configure(:test) { disable :logging }
