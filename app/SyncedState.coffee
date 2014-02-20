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
    @syncedState       = @_addCids(options.syncedState)
    @syncingCommands   = []
    @ajaxQueue         = Queue()
    @simulatedState    = @syncedState

  _addCids: (list) ->
    if typeof list == 'object' # an array
      nextCid = 0
      _.map list, (item) ->
        nextCid += 1
        _.extend(_.clone(item), cid: nextCid)
    else # for testing purposes
      list

  isStillSyncing: =>
    @syncingCommands.length > 0

  simulateAndSyncCommand: (command) =>
    @simulatedState = @doSimulateCommand command, @simulatedState

    if @doSyncCommand == null
      Deferred().resolve() # pretend that we have a server
    else
      @syncingCommands.push command
      addSync = =>
        @doSyncCommand(command, @syncedState)#.then(handleSuccess)
      handleSuccess = (newSyncedState) =>
        @syncedState = newSyncedState
        @syncingCommands.shift()
        # recreate simulatedState, starting from known syncedState
        @simulatedState = @syncedState
        _.each @syncingCommands, (command) =>
          @simulatedState = @doSimulateCommand command, @simulatedState
      handleFailure = (err) =>
        @simulatedState = @syncedState # revert back to last known server state!
        @syncingCommands = [] # throw out all commands!
        throw err
      otherPromise = @ajaxQueue(addSync).then(handleSuccess, handleFailure)

module.exports = SyncedState
