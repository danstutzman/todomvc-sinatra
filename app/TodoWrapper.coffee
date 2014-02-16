Deferred          = require('deferred')
TodoApp           = require('./TodoApp.coffee')
SimulateCommand   = require('./SimulateCommand.coffee')
SyncCommand       = require('./SyncCommand.coffee')
SyncedState       = require('./SyncedState.coffee')
Ajax              = require('./Ajax.coffee')

class TodoWrapper

# TODO: give localhost:9292 url to SyncCommand
# TODO: render server errors and response time

  constructor: (initialTodos, targetDiv) ->
    @syncedState = new SyncedState
      doSimulateCommand: SimulateCommand.doCommand
      doSyncCommand: new SyncCommand(Ajax, 'http://localhost:9292').doCommand
      syncedState: initialTodos
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
    command = args || {}
    command.name = name
    promise = @syncedState.simulateAndSyncCommand(command)
    promise.done @_render, @_render

    @_render() # to show results of simulation

  _render: (err) =>
    React.renderComponent(
      TodoApp
        todos: @syncedState.simulatedState
        nowShowing: @nowShowing
        doCommand: @_doCommand
      @targetDiv)
    if err
      console.error 'show this error to the user:', err
      throw err

module.exports = TodoWrapper
