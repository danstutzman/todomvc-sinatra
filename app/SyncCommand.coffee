_        = require 'underscore'
Deferred = require 'deferred'
Ajax     = require './Ajax.coffee'

SyncCommand =

  doCommand: (command, todos) =>
    name = command.name
    args = _.omit(command, 'name')
    if SyncCommand[name]
      SyncCommand[name].call SyncCommand, args, todos
    else
      throw new Error("Unknown command name #{name}")

  _cidToTodo: (cid, todos) ->
    foundTodo = _.find todos, (todo) ->
      todo.cid == cid
    if foundTodo == undefined
      throw Error("Can't find todo with cid #{cid}")
    foundTodo

  create_todo: (args, todos) ->
    data = JSON.stringify(_.omit(args, 'cid'))
    promise = Ajax.post 'http://localhost:9292/todos', data
    promise.then (newRowJson) ->
      newTodo = _.extend(JSON.parse(newRowJson), cid: args.cid)
      todos.concat(newTodo)

  delete_todo: (args, todos) ->
    todoToDelete = SyncCommand._cidToTodo args.cid, todos
    promise = Ajax.delete "http://localhost:9292/todos/#{todoToDelete.id}"
    promise.then ->
      _.reject todos, (todo) ->
        todo.cid == args.cid

  set_on_todo: (args, todos) =>
    todoToUpdate = SyncCommand._cidToTodo args.cid, todos
    data = JSON.stringify(_.extend(_.omit(args, 'cid'), id: todoToUpdate.id))
    promise = Ajax.put "http://localhost:9292/todos/#{todoToUpdate.id}", data
    promise.then (updatedRowJson) ->
      updatedTodo = _.extend(JSON.parse(updatedRowJson), cid: args.cid)
      _.map todos, (todo) ->
        if todo.cid == args.cid then updatedTodo else todo

  set_on_all_todos: (args, todos) ->
    idToCid = {}
    _.each todos, (todo) ->
      idToCid[todo.id] = todo.cid
    todos = _.map todos, (todo) ->
      _.extend(id: todo.id, args)
    data = JSON.stringify(todos)
    promise = Ajax.put "http://localhost:9292/todos", data
    promise.then (updatedRowsJson) ->
      updatedTodos = _.map JSON.parse(updatedRowsJson), (todo) ->
        _.extend(todo, cid: idToCid[todo.id])

  delete_completed_todos: (args, todos) ->
    previousPromise = Deferred().resolve()
    completedTodos = _.filter todos, (todo) -> todo.completed
    _.each completedTodos, (todo) ->
      previousPromise = previousPromise.then ->
        Ajax.delete "http://localhost:9292/todos/#{todo.id}"
    previousPromise = previousPromise.then ->
      _.filter todos, (todo) -> !todo.completed

module.exports = SyncCommand
