_           = require('underscore')
TodoApp     = require('./TodoApp.coffee')
CommandDoer = require('./CommandDoer.coffee')

class TodoWrapper

  constructor: (initialTodos, targetDiv) ->
    @todos = _.map(initialTodos, (todo, cid) ->
      _.extend(_.clone(todo), cid: cid))
    @nowShowing = 'all'
    @targetDiv = targetDiv

  run: ->
    router = Router
      '/':          => @nowShowing = 'all';       @_render()
      '/active':    => @nowShowing = 'active';    @_render()
      '/completed': => @nowShowing = 'completed'; @_render()
    router.init()
    @_render()

  _doCommand: (name, args) =>
    @todos = CommandDoer.doCommand(name, args, @todos)
    @_render()

  _render: ->
    React.renderComponent(
      TodoApp
        todos: @todos
        nowShowing: @nowShowing
        doCommand: @_doCommand
      @targetDiv)

module.exports = TodoWrapper
