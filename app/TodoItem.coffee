Todo = require('./Todo.coffee')

ESCAPE_KEY = 27
ENTER_KEY = 13

TodoItem = React.createClass
  propTypes:
    todo:      React.PropTypes.instanceOf(Todo).isRequired
    editing:   React.PropTypes.bool.isRequired
    onEdit:    React.PropTypes.func.isRequired
    onSave:    React.PropTypes.func.isRequired
    onDestroy: React.PropTypes.func.isRequired
    onCancel:  React.PropTypes.func.isRequired
    onToggle:  React.PropTypes.func.isRequired

  handleSubmit: ->
    val = @state.editText.trim()
    if val
      @props.onSave val
      @setState editText: val
    else
      @props.onDestroy()
    false

  handleEdit: ->
    # react optimizes renders by batching them. This means you can't call
    # parent's `onEdit` (which in this case triggeres a re-render), and
    # immediately manipulate the DOM as if the rendering's over. Put it as a
    # callback. Refer to app.js' `edit` method
    @props.onEdit (->
      node = @refs.editField.getDOMNode()
      node.focus()
      node.setSelectionRange node.value.length, node.value.length
    ).bind(this)
    @setState editText: @props.todo.get('title')

  handleKeyDown: (event) ->
    if event.keyCode is ESCAPE_KEY
      @setState editText: @props.todo.get('title')
      @props.onCancel()
    else if event.keyCode is ENTER_KEY
      @handleSubmit()

  handleChange: (event) ->
    console.log event
    console.log event.target
    @setState editText: event.target.value

  getInitialState: ->
    editText: @props.todo.get('title')

  shouldComponentUpdate: (nextProps, nextState) ->
    @props.todo.changedAttributes() != false or
    nextProps.editing isnt @props.editing or
    nextState.editText isnt @state.editText

  render: ->
    li_attrs =
      className: React.addons.classSet
        completed: @props.todo.get('completed')
        editing: @props.editing

    label_attrs =
      ref: 'label',
      onDoubleClick: @handleEdit

    check_box_attrs =
      className: 'toggle'
      type: 'checkbox'
      checked: @props.todo.get('completed')
      onChange: @props.onToggle

    edit_box_attrs =
      ref: 'editField'
      className: 'edit'
      value: @state.editText
      onBlur: @handleSubmit
      onChange: @handleChange
      onKeyDown: @handleKeyDown

    React.DOM.li(li_attrs,
      React.DOM.div(className: 'view',
        React.DOM.input(check_box_attrs),
        React.DOM.label(label_attrs, @props.todo.get('title')),
        React.DOM.button(className: 'destroy', onClick: @props.onDestroy)
      ),
      React.DOM.input(edit_box_attrs)
    )

module.exports = TodoItem
