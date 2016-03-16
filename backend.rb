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
  class Device < ActiveRecord::Base
  end

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
      content_type :json
      TodoItem.order(:id).all.to_json
    end

    post '/todos' do
      content_type :json
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
      content_type :json
      out.to_json
    end

    put '/todos/:id' do
      todo = TodoItem[params[:id]]
      hash = JSON.parse(request.body.read)
      id = hash.delete('id')
      todo.update(hash)
      content_type :json
      todo.to_json
    end

    delete '/todos/:id' do
      todo = TodoItem[params[:id]]
      todo.destroy
      'OK'
    end

    get '/learn.json' do
      content_type :json
      '[]'
    end

    def resolve_temp_id(action, temp_id_to_id)
      if action['type'] == 'TODOS/ADD_TODO'
        nil
      else
        id_maybe_temp = action['todoIdMaybeTemp']
        if id_maybe_temp.nil?
          raise "Unexpected missing idMaybeTemp in action #{action.inspect}"
        elsif id_maybe_temp < 0
          temp_id_to_id[id_maybe_temp] or \
            raise "Unexpected todoIdMaybeTemp value in #{action.inspect} doesn't
                   match temp_id_to_id #{temp_id_to_id.inspect}"
        else
          id_maybe_temp
        end
      end
    end

    post '/' do
      body = JSON.parse(request.body.read)

      device = Device.find_by_uid(body['deviceUid'])
      if device.nil?
        begin
          device = Device.create!({
            uid:                              body['deviceUid'],
            completed_action_to_sync_id:      0,
            action_to_sync_id_to_output_json: '{}',
          })
        rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
          device = Device.find_by_uid(body['deviceUid'])
        end
      end

      TodoItem.transaction do
        new_action_to_sync_ids = {}
        body['actionsToSync'].each do |action|
          new_action_to_sync_ids[action['id']] = true
        end
        action_to_sync_id_to_output = JSON.parse(
          device.action_to_sync_id_to_output_json).delete_if { |action_to_sync_id|
            new_action_to_sync_ids[action_to_sync_id] }
        action_to_sync_id_to_output = Hash[action_to_sync_id_to_output.keys.map {
          |key| key.to_i }.zip(action_to_sync_id_to_output.values)]

        temp_id_to_id = {}
        body['actionsToSync'].each do |action|
          output = action_to_sync_id_to_output[action['id']]
          if output == nil
            todo_id = resolve_temp_id action, temp_id_to_id
            output = case action['type']
              when 'TODO/SET_COMPLETED'
                TodoItem.update todo_id, completed: action['completed']
                true
              when 'TODO/SET_TITLE'
                TodoItem.update todo_id, title: action['title']
                true
              when 'TODOS/DELETE_TODO'
                TodoItem.where(id: todo_id).delete_all
                true
              when 'TODOS/ADD_TODO'
                if todo_id != nil
                  raise "Unexpectedly non-nil todo_id from #{action.inspect}"
                end
                todo = TodoItem.create!({
                  title:     action['title'],
                  completed: action['completed'],
                })
                temp_id_to_id[action['todoIdMaybeTemp']] = todo.id
                todo.id
              else
                raise "Unknown action type '#{action['type']}'"
            end
            action_to_sync_id_to_output[action['id']] = output
          end
        end # loop through actionsToSync

        device.update({
          completed_action_to_sync_id: action_to_sync_id_to_output.keys.max || 0,
          action_to_sync_id_to_output_json: JSON.generate(action_to_sync_id_to_output),
        })
        device.save!
      end # transaction

      content_type :json
      {
        todos:                  TodoItem.order(:id),
        actionToSyncIdToOutput: JSON.parse(device.action_to_sync_id_to_output_json),
      }.to_json
    end
  end
end

#configure(:test) { disable :logging }
