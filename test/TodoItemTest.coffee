assert      = require 'assert'
prettyPrint = require('html').prettyPrint
helper      = require '../test/helper.coffee'
TodoItem    = require '../app/TodoItem.coffee'

NOOP = ->

ENTER_KEY  = 13
ESCAPE_KEY = 27

# Fixture
F1 = { cid: 5, title: 'before', completed: false, id: 6 }

describe 'TodoItem', ->
  beforeEach ->
    @item = TodoItem todo: F1, doCommand: NOOP

  it 'can handleSubmit (changed)', (done) ->
    @item.props.doCommand = (name, args) ->
      assert.equal name, 'set_on_todo'
      assert.deepEqual args, cid: 5, title: 'after'
      done()
    @item.state = { editText: 'after' }
    @item.setState = NOOP
    @item.handleSubmit()

  it 'can handleSubmit (no change)', (done) ->
    @item.props.doCommand = (name, args) ->
      assert false # doCommand should not be called
    @item.state = { editText: F1.title }
    @item.setState = NOOP
    @item.handleSubmit()
    done()

  it 'can handleSubmit (empty to delete)', (done) ->
    @item.props.doCommand = (name, args) ->
      assert.equal name, 'delete_todo'
      assert.deepEqual args, cid: 5
      done()
    @item.state = { editText: '' }
    @item.setState = NOOP
    @item.handleSubmit()

  it 'can handleEdit', (done) ->
    @item.setState = (args, callback) =>
      assert.deepEqual args, editText: 'before', isEditing: true
      # hack for code coverage
      @item.refs =
        editField:
          getDOMNode: ->
            value: ''
            focus: ->
            setSelectionRange: ->
      callback.call @item
      done()
    @item.handleEdit()

  it 'can handleKeyDown (Enter)', (done) ->
    @item.handleSubmit = -> done()
    @item.handleKeyDown keyCode: ENTER_KEY

  it 'can handleKeyDown (Escape)', (done) ->
    @item.setState = (args) ->
      assert.deepEqual args, editText: 'before', isEditing: false
      done()
    @item.handleKeyDown keyCode: ESCAPE_KEY

  it 'can handleKeyDown (other, for coverage)', ->
    @item.handleKeyDown keyCode: 'a'.charCodeAt(0)

  it 'can handleChange', (done) ->
    @item.setState = (args) ->
      assert.deepEqual args, editText: 'after'
      done()
    @item.handleChange target: { value: 'after' }

  it 'can handleToggle to true', (done) ->
    @item.props.doCommand = (name, args) ->
      assert.equal name, 'set_on_todo'
      assert.deepEqual args, cid: 5, completed: true
      done()
    @item.handleToggle()

  it 'can handleToggle to false', (done) ->
    todo = { cid: 5, title: 'before', completed: true }
    @item = TodoItem todo: todo, doCommand: (name, args) ->
      assert.equal name, 'set_on_todo'
      assert.deepEqual args, cid: 5, completed: false
      done()
    @item.handleToggle()

  it 'can handleDestroy', (done) ->
    @item.props.doCommand = (name, args) ->
      assert.equal name, 'delete_todo'
      assert.deepEqual args, cid: 5
      done()
    @item.handleDestroy()

  it 'updates (title changed)', ->
    @item.state = isEditing: false
    nextProps = todo: { cid: 5, title: 'different', completed: false }
    nextState = isEditing: true
    assert @item.shouldComponentUpdate(nextProps, nextState)

  it 'updates (isEditing changed)', ->
    @item.state = isEditing: false, editText: 'new'
    nextProps = @item.props
    nextState = isEditing: true, editText: 'new'
    assert @item.shouldComponentUpdate(@item.props, nextState)

  it 'updates (editText changed)', ->
    @item.state = isEditing: false, editText: 'before'
    nextProps = @item.props
    nextState = isEditing: true, editText: 'after'
    assert @item.shouldComponentUpdate(@item.props, nextState)

  it "doesn't update when not necessary", ->
    @item.state = isEditing: true, editText: 'new'
    nextProps = @item.props
    nextState = isEditing: true, editText: 'new'
    assert not @item.shouldComponentUpdate(@item.props, nextState)

  it 'can render (not editing)', (done) ->
    helper.assertRendersHtml @item, done, """
<li class="">
  <div style="font-size:8pt;float:right;">cid 5, id 6</div>
  <div class="view">
    <input class="toggle" type="checkbox">
    <label>before</label>
    <button class="destroy"></button>
  </div>
  <input class="edit" value="before">
</li>
"""

  it 'can render (editing)', (done) ->
    @item.props.initialState = isEditing: true, editText: 'in progress'
    helper.assertRendersHtml @item, done, """
<li class="editing ">
  <div style="font-size:8pt;float:right;">cid 5, id 6</div>
  <div class="view">
    <input class="toggle" type="checkbox">
    <label>before</label>
    <button class="destroy"></button>
  </div>
  <input class="edit" value="in progress">
</li>
"""

  it 'can render (completed)', (done) ->
    @item.props.todo.completed = true
    helper.assertRendersHtml @item, done, """
<li class="completed ">
  <div style="font-size:8pt;float:right;">cid 5, id 6</div>
  <div class="view">
    <input class="toggle" type="checkbox" checked="true">
    <label>before</label>
    <button class="destroy"></button>
  </div>
  <input class="edit" value="before">
</li>
"""
