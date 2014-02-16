_        = require 'underscore'
Deferred = require 'deferred'

class SyncCommand
  constructor: (ajax, url) ->
    @ajax = ajax
    @url = url

  doCommand: (command, todos) =>
    name = command.name
    args = _.omit(command, 'name')
    if this[name]
      this[name].call this, args, todos
    else
      throw new Error("Unknown command name #{name}")

  _cidToTodo: (cid, todos) ->
    foundTodo = _.find todos, (todo) ->
      todo.cid == cid
    if foundTodo == undefined
      throw Error("Can't find todo with cid #{cid}")
    foundTodo

  create_todo: (args, todos) ->
    data = _.omit(args, 'cid')
    promise = @ajax.post "#{@url}/todos", data
    promise.then (newRowJson) ->
      newTodo = _.extend(JSON.parse(newRowJson), cid: args.cid)
      todos.concat(newTodo)

  delete_todo: (args, todos) ->
    todoToDelete = @_cidToTodo args.cid, todos
    promise = @ajax.delete "#{@url}/todos/#{todoToDelete.id}"
    promise.then ->
      _.reject todos, (todo) ->
        todo.cid == args.cid

  set_on_todo: (args, todos) ->
    todoToUpdate = @_cidToTodo args.cid, todos
    data = _.extend(_.omit(args, 'cid'), id: todoToUpdate.id)
    promise = @ajax.put "#{@url}/todos/#{todoToUpdate.id}", data
    promise.then (updatedRowJson) ->
      updatedTodo = _.extend(JSON.parse(updatedRowJson), cid: args.cid)
      _.map todos, (todo) ->
        if todo.cid == args.cid then updatedTodo else todo

  set_on_all_todos: (args, todos) ->
    idToCid = {}
    _.each todos, (todo) ->
      idToCid[todo.id] = todo.cid
    data = _.map todos, (todo) ->
      _.extend(id: todo.id, args)
    promise = @ajax.put "#{@url}/todos", data
    promise.then (updatedRowsJson) ->
      updatedTodos = _.map JSON.parse(updatedRowsJson), (todo) ->
        _.extend(todo, cid: idToCid[todo.id])

  delete_completed_todos: (args, todos) ->
    previousPromise = Deferred().resolve()
    completedTodos = _.filter todos, (todo) -> todo.completed
    _.each completedTodos, (todo) =>
      previousPromise = previousPromise.then =>
        @ajax.delete "#{@url}/todos/#{todo.id}"
    previousPromise = previousPromise.then ->
      _.filter todos, (todo) -> !todo.completed

module.exports = SyncCommand
