React = require 'react'

ESCAPE_KEY = 27
ENTER_KEY  = 13
type       = React.PropTypes

TodoItem = React.createClass

  propTypes:
    todo:      type.object.isRequired
    doCommand: type.func.isRequired

  getInitialState: ->
    @props.initialState or # Supply initialState for testing from node
      isEditing: false
      editText: @props.todo.title

  # warning: may be called twice
  handleSubmit: ->
    val = @state.editText.trim()
    if val == ''
      @props.doCommand 'delete_todo', cid: @props.todo.cid
    else if val != @props.todo.title
      @props.doCommand 'set_on_todo', cid: @props.todo.cid, title: val
    @setState isEditing: false

  handleEdit: ->
    @setState editText: @props.todo.title, isEditing: true, ->
      node = @refs.editField.getDOMNode()
      node.focus()
      node.setSelectionRange node.value.length, node.value.length

  handleKeyDown: (event) ->
    if event.keyCode is ESCAPE_KEY
      @setState editText: @props.todo.title, isEditing: false
    else if event.keyCode is ENTER_KEY
      @handleSubmit()

  handleChange: (event) ->
    @setState editText: event.target.value

  handleToggle: (event) ->
    @props.doCommand 'set_on_todo',
      cid: @props.todo.cid, completed: !@props.todo.completed

  shouldComponentUpdate: (nextProps, nextState) ->
    nextProps.todo      != @props.todo      or
    nextState.isEditing != @state.isEditing or
    nextState.editText  != @state.editText

  handleDestroy: (event) ->
    @props.doCommand 'delete_todo', cid: @props.todo.cid

  render: ->
    { button, div, input, label, li } = React.DOM
    li
      className:
        (@props.todo.completed && 'completed ' || '') +
        (@state.isEditing      && 'editing '   || '')
      div
        style: { 'font-size': '8pt', float: 'right' }
        "cid #{@props.todo.cid}, id #{@props.todo.id}"
      div
        className: 'view'
        input
          className: 'toggle'
          type: 'checkbox'
          checked: @props.todo.completed
          onChange: @handleToggle
        label
          onDoubleClick: @handleEdit
          @props.todo.title
        button
          className: 'destroy'
          onClick: @handleDestroy
      input
        ref: 'editField'
        className: 'edit'
        value: @state.editText
        onBlur: @handleSubmit
        onChange: @handleChange
        onKeyDown: @handleKeyDown

module.exports = TodoItem
