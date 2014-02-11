CommandDoer = require('../app/CommandDoer.coffee')

describe "Misc. for complete coverage", ->
  it "CommandDoer errors when it doesn't understand the command", ->
    doer = new CommandDoer([])
    expect(-> doer.doCommand 'unknown').toThrow()
