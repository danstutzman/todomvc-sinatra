_           = require 'underscore'
assert      = require 'assert'
Deferred    = require 'deferred'
SyncCommand = require '../app/SyncCommand.coffee'

makeSyncCommand = (handler) ->
  promise_handler = (method, path, data) ->
    faked_response = handler(method, path, data)
    Deferred().resolve(faked_response)
  ajax =
    get:    (path, data) -> promise_handler 'GET',    path, data
    post:   (path, data) -> promise_handler 'POST',   path, data
    put:    (path, data) -> promise_handler 'PUT',    path, data
    delete: (path, data) -> promise_handler 'DELETE', path, data
  new SyncCommand(ajax, '')

# Fixtures
F1 = { cid:1, x:1, id:-1 }
F2 = { cid:2, x:2, id:-2 }

describe 'SyncCommand', ->

  it 'can create_todo', (done) ->
    base = title: 'test', completed: false
    sync = makeSyncCommand (method, path, data) ->
      assert.equal method, 'POST'
      assert.equal path, '/todos'
      assert.deepEqual data, { x:2 }
      '{"x":2,"id":-2}'
    promise = sync.create_todo(cid:2, x:2, [F1]).done (todos) ->
      assert.deepEqual todos, [F1, F2]
      done()

  it 'can delete_todo', (done) ->
    sync = makeSyncCommand (method, path, data) ->
      assert.equal method, 'DELETE'
      assert.equal path, '/todos/-1'
      'ok'
    promise = sync.delete_todo(cid:1, [F1, F2]).done (todos) ->
      assert.deepEqual todos, [F2]
      done()

  it 'can set_on_todo', (done) ->
    sync = makeSyncCommand (method, path, data) ->
      assert.equal method, 'PUT'
      assert.equal path, '/todos/-1'
      '{"x":11,"id":-1}'
    sync.set_on_todo(cid:1, x:11, [F1, F2]).done (todos) ->
      assert.deepEqual todos, [{ cid:1, x:11, id:-1 }, F2]
      done()

  it 'can set_on_all_todos', (done) ->
    sync = makeSyncCommand (method, path, data) ->
      assert.equal method, 'PUT'
      assert.equal path, '/todos'
      '[{"x":9,"id":-1},{"x":9,"id":-2}]'
    sync.set_on_all_todos(x:9, [F1, F2]).done (todos) ->
      assert.deepEqual todos, [{ cid:1, x:9, id:-1 }, { cid:2, x:9, id:-2 }]
      done()

  it 'can delete_completed_todos', (done) ->
    i = 0
    sync = makeSyncCommand (method, path, data) ->
      assert.equal method, 'DELETE'
      assert.equal path, '/todos/-2' if i == 0
      assert.equal path, '/todos/-3' if i == 1
      i += 1
      'ok'
    todos = [{ cid:1, completed:false, id:-1 },
             { cid:2, completed:true,  id:-2 },
             { cid:3, completed:true,  id:-3 }]
    sync.delete_completed_todos({}, todos).done (todos) ->
      assert.deepEqual todos, [{ cid:1, completed:false, id:-1 }]
      done()
