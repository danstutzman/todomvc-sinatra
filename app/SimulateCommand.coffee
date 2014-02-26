_ = require('underscore')

SimulateCommand =

  doCommand: (command, todos) ->
    name = command.name
    args = command
    if SimulateCommand[name]
      SimulateCommand[name].call SimulateCommand, args, todos
    else
      throw new Error("Unknown command name #{name}")

  _set: (todo, changes) ->
    newTodo = _.clone(todo)
    _.extend newTodo, changes

  create_todo: (args, todos) ->
    _.extend(todos.concat(args))

  delete_todo: (args, todos) ->
    _.reject todos, (todo) ->
      todo.cid == args.cid

  set_on_all_todos: (args, todos) ->
    todos.map (todo) =>
      @_set todo, completed: args.completed

  set_on_todo: (args, todos) ->
    todos.map (todo) =>
      if todo.cid == args.cid
        @_set todo, args
      else
        todo

  delete_completed_todos: (args, todos) ->
    _.reject todos, (todo) ->
      todo.completed == true

module.exports = SimulateCommand
