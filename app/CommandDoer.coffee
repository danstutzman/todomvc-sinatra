_ = require('underscore')

CommandDoer =

  doCommand: (name, args, todos) =>
    if CommandDoer[name]
      CommandDoer[name].call CommandDoer, args, todos
    else
      throw new Error("Unknown command name #{name}")

  _set: (todo, changes) ->
    newTodo = _.clone(todo)
    _.extend newTodo, changes

  create_todo: (args, todos) ->
    maxCid = -1
    _.each todos, (todo) ->
      if todo.cid > maxCid
        maxCid = todo.cid
    newTodo = { cid: maxCid + 1, title: args.title }
    todos.concat(newTodo)

  delete_todo: (args, todos) ->
    _.reject todos, (todo) ->
      todo.cid == args.cid

  toggle_completed_on_todo: (args, todos) ->
    todos.map (todo) =>
      if todo.cid == args.cid
        @_set todo, completed: not todo.completed
      else
        todo

  set_completed_on_all_todos: (args, todos) ->
    todos.map (todo) =>
      @_set todo, completed: args.completed

  set_title_on_todo: (args, todos) ->
    todos.map (todo) =>
      if todo.cid == args.cid
        @_set todo, title: args.title
      else
        todo

  delete_completed_todos: (args, todos) ->
    _.reject todos, (todo) =>
      todo.completed == true

module.exports = CommandDoer
