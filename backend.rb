require 'rubygems'
require 'bundler'
Bundler.setup

require 'logger'
require 'json'
require 'dotenv'
require 'active_record'
require 'sinatra'
require 'sinatra/activerecord'
require 'thin'

RACK_ENV = ENV['RACK_ENV'] || 'development'
Dotenv.load! ".env.#{RACK_ENV}"

module TodomvcBackend
  class TodoItem < ActiveRecord::Base
  end

  class App < Sinatra::Application
    register Sinatra::ActiveRecordExtension

    configure do
      disable :method_override
      set :sessions,
          httponly:     true,
          secure:       production?,
          expire_after: 60 * 60 * 24 * 365,
          secret:       ENV['SESSION_SECRET']
      set static: true
      # gotta set root or it'll be set wrong during automated tests
      set root: File.dirname(__FILE__)
      set :public_folder, Proc.new { File.join(root, ENV['PUBLIC_DIR']) }
    end

    use Rack::Deflater
    use Rack::Logger

    get '/' do
      `rake app/concat` if RACK_ENV == 'development'

      todo_json = TodoItem.order(:id).all.to_json

      html = File.read("#{ENV['PUBLIC_DIR']}/index.html")
      html.sub! /var initialTodos = \[\];/, "var initialTodos = #{todo_json};"
      html
    end

    get '/todos' do
      TodoItem.order(:id).all.to_json
    end

    post '/todos' do
      hash = JSON.parse(request.body.read)
      todo = TodoItem.new(hash.reject { |key| key == 'id' })
      todo.save
      todo.to_json
    end

    # just updates, not creates or deletes
    put '/todos' do
      hashes = JSON.parse(request.body.read)
      ids = TodoItem.select(:id).map { |todo| todo.id }
      out = hashes.map do |hash|
        todo = TodoItem.find(id: hash['id'])
        todo.update(hash.reject { |key| key == 'id' })
        todo
      end
      out.to_json
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
