Todo = require('./Todo.coffee')

ESCAPE_KEY = 27
ENTER_KEY  = 13
type       = React.PropTypes

TodoItem = React.createClass
  propTypes:
    todo:      type.instanceOf(Todo).isRequired
    doCommand: type.func.isRequired

  getInitialState: ->
    isEditing: false
    editText: @props.todo.get('title')

  # warning: may be called twice
  handleSubmit: ->
    val = @state.editText.trim()
    if val == ''
      @props.doCommand 'delete_todo', cid: @props.todo.cid
    else if val != @props.todo.get('title')
      @props.doCommand 'set_title_on_todo',
        cid: @props.todo.cid, title: val
    @setState isEditing: false

  handleEdit: ->
    @setState editText: @props.todo.get('title'), isEditing: true, ->
      node = @refs.editField.getDOMNode()
      node.focus()
      node.setSelectionRange node.value.length, node.value.length

  handleKeyDown: (event) ->
    if event.keyCode is ESCAPE_KEY
      @setState editText: @props.todo.get('title'), isEditing: false
    else if event.keyCode is ENTER_KEY
      @handleSubmit()

  handleChange: (event) ->
    @setState editText: event.target.value

  handleToggle: (event) ->
    @props.doCommand 'toggle_completed_on_todo', cid: @props.todo.cid

  shouldComponentUpdate: (nextProps, nextState) ->
    @props.todo.changedAttributes() != false or
    nextState.isEditing isnt @state.isEditing or
    nextState.editText isnt @state.editText

  handleDestroy: (event) ->
    @props.doCommand 'delete_todo', cid: @props.todo.cid

  render: ->
    { button, div, input, label, li } = React.DOM
    li
      className:
        (@props.todo.get('completed') && 'completed ') +
        (@state.isEditing             && 'editing ')
      div
        className: 'view'
        input
          className: 'toggle'
          type: 'checkbox'
          checked: @props.todo.get('completed')
          onChange: @handleToggle
        label
          onDoubleClick: @handleEdit
          @props.todo.get('title')
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
