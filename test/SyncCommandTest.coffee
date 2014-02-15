SyncCommand = require('../app/SyncCommand.coffee')

describe 'SyncCommand', ->
  it 'can create', ->
    SyncCommand.create_todo cid: 1, title: 'test', completed: false
