assert      = require 'assert'
Deferred    = require 'deferred'
SyncedState = require '../app/SyncedState.coffee'

PromisedPart = (callbackTakesPartDone) ->
  deferred = Deferred()
  callbackTakesPartDone (-> deferred.resolve())
  deferred.promise

describe 'SyncedState', ->

  it 'starts with bootstrapped', ->
    state = new SyncedState
      doSimulateCommand: ->
      doSyncCommand: -> Deferred().promise
      syncedState: 0
    assert.equal state.simulatedState, 0

  it 'simulates immediately', ->
    state = new SyncedState
      doSimulateCommand: -> -1
      doSyncCommand: -> Deferred().promise
      syncedState: 0
    state.simulateAndSyncCommand(name: 'increment')
    assert.equal state.simulatedState, -1

  it 'calls back after server succeeds', (done) ->
    server1 = new Deferred()
    state = new SyncedState
      doSimulateCommand: -> -1
      doSyncCommand: (command, syncedState) ->
        assert.deepEqual command, name: 'increment'
        assert.equal syncedState, 0
        server1.promise
      syncedState: 0
    state.simulateAndSyncCommand(name: 'increment').done ->
      assert.equal state.simulatedState, 1
      done()
    assert.equal state.simulatedState, -1
    server1.resolve 1

  it 'calls back after server fails', (done) ->
    server1 = new Deferred()
    state = new SyncedState
      doSimulateCommand: -> -1
      doSyncCommand: (command, syncedState) ->
        assert.equal syncedState, 0
        server1.promise
      syncedState: 0
    state.simulateAndSyncCommand(name: 'increment').done null, (err) ->
      assert.equal state.simulatedState, 0
      done()
    assert.equal state.simulatedState, -1
    server1.reject Error('server error')

  it 'queues 1, resolves 1, queues 2, resolves 2', (done) ->
    server1 = new Deferred()
    server2 = new Deferred()
    state = new SyncedState
      doSimulateCommand: -> -1
      doSyncCommand: (command, syncedState) ->
        assert.equal syncedState, 0
        server1.promise
      syncedState: 0

    part1 = PromisedPart (done) ->
      state.simulateAndSyncCommand(name: 'increment').done ->
        assert.equal state.simulatedState, 1
        done()
      server1.resolve 1

    part2 = PromisedPart (done) ->
      state.doSimulateCommand = -> -2
      state.doSyncCommand = (command, syncedState) ->
        assert.equal syncedState, 1
        server2.promise
      state.simulateAndSyncCommand(name: 'increment').done ->
        assert.equal state.simulatedState, 2
        done()
      server2.resolve 2

    Deferred().resolve().then(part1).then(part2).done(done)

  it 'queues 1, queues 2, resolves 1, resolves 2', (done) ->
    server1 = new Deferred()
    server2 = new Deferred()
    state = new SyncedState
      doSimulateCommand: -> -1
      doSyncCommand: (command, syncedState) ->
        assert.equal syncedState, 0
        server1.promise
      syncedState: 0

    state.simulateAndSyncCommand(name: 'increment').done ->
      assert.equal state.simulatedState, -2 # NOT 1, because we still have 2 queued
    state.doSimulateCommand = -> -2
    state.doSyncCommand = (command, syncedState) ->
      assert.equal syncedState, 1
      server2.promise
    state.simulateAndSyncCommand(name: 'increment').done ->
      assert.equal state.simulatedState, 2
      done()
    server1.resolve 1
    server2.resolve 2

  it 'queues 1, queues 2, resolves 1, rejects 2', (done) ->
    server1 = new Deferred()
    server2 = new Deferred()
    state = new SyncedState
      doSimulateCommand: -> -1
      doSyncCommand: (command, syncedState) ->
        assert.equal syncedState, 0
        server1.promise
      syncedState: 0

    state.simulateAndSyncCommand(name: 'increment').done ->
      assert.equal state.syncedState, 1
      assert.equal state.simulatedState, -2 # NOT 1, because we still have 2 queued

    state.doSimulateCommand = -> -2
    state.doSyncCommand = (command, syncedState) ->
      assert.equal syncedState, 0 # STILL at 0
      server2.promise
    state.simulateAndSyncCommand(name: 'increment').done null, (err) ->
      assert.equal state.syncedState, 1 # it reverted to 1
      assert.equal state.simulatedState, 1 # it reverted to 1
      done()
    server1.resolve 1
    server2.reject Error('server error')

  it 'queues 1, queues 2, rejects 1 and 2', (done) ->
    server1 = new Deferred()
    server2 = new Deferred()
    state = new SyncedState
      doSimulateCommand: -> -1
      doSyncCommand: -> server1.promise
      syncedState: 0

    state.simulateAndSyncCommand(name: 'increment').done null, (err) ->
      assert.equal state.simulatedState, 0 # rollback
    state.doSimulateCommand = -> -2
    state.doSyncCommand = -> server2.promise
    state.simulateAndSyncCommand(name: 'increment').done null, (err) ->
      assert.equal state.simulatedState, 0 # not applied either
      done()
    server1.reject Error('server error')
    # don't need to reject server2; it's rejected too

  it 'queues 1, rejects 1, queues 2, resolves 2', (done) ->
    server1 = new Deferred()
    server2 = new Deferred()
    state = new SyncedState
      doSimulateCommand: -> -1
      doSyncCommand: -> server1.promise
      syncedState: 0

    state.simulateAndSyncCommand(name: 'increment').done null, (err) ->
      assert.equal state.simulatedState, 0 # rollback
    server1.reject Error('server error')

    state.doSimulateCommand = -> -2
    state.doSyncCommand = -> server2.promise
    state.simulateAndSyncCommand(name: 'increment').done ->
      assert.equal state.simulatedState, 2
      done()
    server2.resolve 2
