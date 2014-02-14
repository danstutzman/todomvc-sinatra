CommandDoer = require('../app/CommandDoer.coffee')

describe "Misc. for complete coverage", ->
  it "CommandDoer errors when it doesn't understand the command", ->
    expect(-> CommandDoer.doCommand 'unknown').toThrow()
