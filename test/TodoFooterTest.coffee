assert      = require 'assert'
prettyPrint = require('html').prettyPrint
helper      = require '../test/helper.coffee'
TodoFooter  = require '../app/TodoFooter.coffee'

NOOP = ->

describe 'TodoFooter', ->

  it 'can handleClearCompleted', (done) ->
    tf = new TodoFooter doCommand: (name, args) ->
      assert.equal name, 'delete_completed_todos'
      done()
    tf.handleClearCompleted()

  it 'can render with >1 items', (done) ->
    props =
      count: 4
      completedCount: 1
      nowShowing: 'all'
      doCommand: NOOP
    helper.assertRendersHtml TodoFooter(props), done, """
<div id="footer">
  <span id="todo-count">
    <strong>4</strong>
    <span>items left</span>
  </span>
  <ul id="filters">
    <li>
      <a href="#&#x2f;" class="selected">All</a>
    </li>
    <span></span>
    <li>
      <a href="#&#x2f;active">Active</a>
    </li>
    <span></span>
    <li>
      <a href="#&#x2f;completed">Completed</a>
    </li>
  </ul>
  <button id="clear-completed">Clear completed (1)</button>
</div>
"""

  it 'can render with 1 item, none completed', (done) ->
    props =
      count: 1
      completedCount: 0
      nowShowing: 'all'
      doCommand: NOOP
    helper.assertRendersHtml TodoFooter(props), done, """
<div id="footer">
  <span id="todo-count">
    <strong>1</strong>
    <span>item left</span>
  </span>
  <ul id="filters">
    <li>
      <a href="#&#x2f;" class="selected">All</a>
    </li>
    <span></span>
    <li>
      <a href="#&#x2f;active">Active</a>
    </li>
    <span></span>
    <li>
      <a href="#&#x2f;completed">Completed</a>
    </li>
  </ul>
</div>
"""
