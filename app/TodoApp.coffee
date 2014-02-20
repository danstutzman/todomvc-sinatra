_              = require('underscore')
React          = require('react')
TodoItem       = require('./TodoItem.coffee')
TodoFooter     = require('./TodoFooter.coffee')

ENTER_KEY              = 13
type                   = React.PropTypes

TodoApp = React.createClass

  displayName: 'TodoApp'

  getInitialState: ->
    maxCid = _.reduce @props.todos,
      (memo, todo) -> if todo.cid > memo then todo.cid else memo
      0
    { nextCid: maxCid + 1}

  propTypes:
    todos:      type.array.isRequired
    nowShowing: type.string.isRequired
    doCommand:  type.func.isRequired

  componentDidMount: ->
    window.setTimeout (=> @refs.newField.getDOMNode().focus()), 0

  handleNewTodoKeyDown: (event) ->
    return if event.keyCode != ENTER_KEY
    val = @refs.newField.getDOMNode().value.trim()
    if val
      nextCid = @state.nextCid
      @setState nextCid: nextCid + 1
      @props.doCommand 'create_todo', cid: nextCid, title: val, completed: false
      @refs.newField.getDOMNode().value = ''

  handleToggleAll: (event) ->
    @props.doCommand 'set_on_all_todos', completed: event.target.checked

  render: ->
    activeTodos = _.filter @props.todos, (todo) ->
      not todo.completed

    completedTodos = _.filter @props.todos, (todo) ->
      todo.completed

    passingTodos = switch @props.nowShowing
      when 'all'           then @props.todos
      when 'active'        then activeTodos
      when 'completed'     then completedTodos

    { div, h1, input, section, ul } = React.DOM

    div {},
      div
        id: 'header',
        h1 {},
          'todos'
        input
          ref: 'newField'
          id: 'new-todo'
          placeholder: 'What needs to be done?'
          onKeyDown: @handleNewTodoKeyDown
      if passingTodos.length
        div
          id: 'main'
          className: 'section'
          React.DOM.input
            id: 'toggle-all'
            type: 'checkbox'
            onChange: @handleToggleAll
            checked: activeTodos.length == 0
          ul
            id: 'todo-list'
            passingTodos.map (todo) =>
              TodoItem
                key: todo.cid
                todo: todo
                doCommand: @props.doCommand
      if activeTodos.length or completedTodos.length
        TodoFooter
          ref: 'footer'
          count: activeTodos.length
          completedCount: completedTodos.length
          nowShowing: @props.nowShowing
          doCommand: @props.doCommand

module.exports = TodoApp
