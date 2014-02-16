require 'rspec'
require 'rack/test'
require 'pry'
require 'database_cleaner'
require './backend'

describe 'TodomvcBackend::App' do
  include Rack::Test::Methods

  def app
    TodomvcBackend::App
  end

  def body_is(expected)
    if last_response.status != 200
      File.open 'debug.html', 'w' do |file|
        file.write last_response.body
      end
      `open debug.html`
    else
      if expected == 'OK'
        expect(last_response.body).to eq('OK')
      else
        expected = JSON.parse(JSON.generate(expected))
        expect(JSON.parse(last_response.body)).to eq(expected)
      end
    end
  end

  before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    $db << 'alter sequence todo_items_id_seq restart with 1'
    todo = TodomvcBackend::TodoItem.new title: 'test', completed: false
    todo.save
  end

  it 'GETs all /todos' do
    get '/todos'
    body_is [{ id:1, title:'test', completed:false }]
  end

  it 'POSTs to create a new todo' do
    post '/todos', '{"title":"test","completed":false}'
    body_is id: 2, title: 'test', completed: false
  end

  it 'PUTs to update a todo' do
    put '/todos/1', '{"id":1,"title":"test","completed":false}'
    body_is id: 1, title: 'test', completed: false
  end

  it 'PUTs to update a bunch of todos' do
    put '/todos', '[{"id":1,"title":"test","completed":false}]'
    body_is [{ id: 1, title: 'test', completed: false }]
  end

  it 'DELETEs a todo' do
    delete '/todos/1'
    body_is 'OK'
  end

end
