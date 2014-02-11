TodoItem   = require('./TodoItem.coffee')
TodoFooter = require('./TodoFooter.coffee')
Todo       = require('./Todo.coffee')
Todos      = require('./Todos.coffee')

window.ALL_TODOS       = 'all'
window.ACTIVE_TODOS    = 'active'
window.COMPLETED_TODOS = 'completed'
ENTER_KEY              = 13
type                   = React.PropTypes

TodoApp = React.createClass

  displayName: 'TodoApp'

  propTypes:
    todos:      type.instanceOf(Todos).isRequired
    doCommand:  type.func.isRequired

  getInitialState: ->
    nowShowing: ALL_TODOS

  componentDidMount: ->
    router = Router
      '/':          @setState.bind(this, nowShowing: ALL_TODOS)
      '/active':    @setState.bind(this, nowShowing: ACTIVE_TODOS)
      '/completed': @setState.bind(this, nowShowing: COMPLETED_TODOS)
    router.init()
    @refs.newField.getDOMNode().focus()

  handleNewTodoKeyDown: (event) ->
    return if event.keyCode != ENTER_KEY
    val = @refs.newField.getDOMNode().value.trim()
    if val
      @props.doCommand 'create_todo', title: val
      @refs.newField.getDOMNode().value = ''

  handleToggleAll: (event) ->
    @props.doCommand 'set_completed_on_all_todos',
      completed: event.target.checked

  render: ->
    activeTodos = @props.todos.filter (todo) ->
      not todo.get('completed')

    completedTodos = @props.todos.filter (todo) ->
      todo.get('completed')

    passingTodos = switch @state.nowShowing
      when ACTIVE_TODOS    then activeTodos
      when COMPLETED_TODOS then completedTodos
      else @props.todos

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
        section
          id: 'main'
          React.DOM.input
            id: 'toggle-all'
            ref: 'toggle_all'
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
          nowShowing: @state.nowShowing
          doCommand: @props.doCommand

module.exports = TodoApp
