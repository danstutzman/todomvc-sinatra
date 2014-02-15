_        = require('underscore')
Deferred = require('deferred')

Queue = ->
  previous = Deferred().resolve()
  (fn, fail) ->
    if typeof fn != 'function'
      throw 'must be a function'
    # If the previous request is already finished by the time a new one is
    # added, don't chain the requests, because if the previous one errored,
    # it would immediately reject the new one too.  Instead, start from a
    # success again.
    if previous.resolved
      previous = Deferred().resolve().then(fn, fail)
    else
      previous = previous.then(fn, fail)

class SyncedState

  constructor: (options) ->
    if options                   == undefined ||
       options.doSimulateCommand == undefined ||
       options.doSyncCommand     == undefined ||
       options.syncedState       == undefined
         throw Error('First argument should be
         { doSimulateCommand, doSyncCommand, syncedState }')
    @doSimulateCommand = options.doSimulateCommand
    @doSyncCommand     = options.doSyncCommand
    @syncedState       = options.syncedState
    @syncingCommands   = []
    @ajaxQueue         = Queue()
    @simulatedState    = @syncedState

  simulateAndSyncCommand: (command) =>
    @syncingCommands.push command
    @simulatedState = @doSimulateCommand command, @simulatedState

    addSync = =>
      handleSuccess = (newSyncedState) =>
        @syncedState = newSyncedState
        @syncingCommands.pop()
        # recreate simulatedState, starting from known syncedState
        @simulatedState = @syncedState
        _.each @syncingCommands, (command) =>
          @simulatedState = @doSimulateCommand command, @simulatedState
      handleFailure = (err) =>
        @simulatedState = @syncedState # revert back to last known server state!
        @syncingCommands = [] # throw out all commands!
        throw err
      @doSyncCommand(command).then(handleSuccess, handleFailure)
    otherPromise = @ajaxQueue addSync

module.exports = SyncedState
