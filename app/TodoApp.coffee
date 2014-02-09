Utils      = require('./Utils.coffee')
TodoItem   = require('./TodoItem.coffee')
TodoFooter = require('./TodoFooter.coffee')
Todo       = require('./Todo.coffee')
Todos      = require('./Todos.coffee')

window.ALL_TODOS       = 'all'
window.ACTIVE_TODOS    = 'active'
window.COMPLETED_TODOS = 'completed'
ENTER_KEY = 13

TodoApp = React.createClass

  displayName: 'TodoApp'

  propTypes:
    todos:      React.PropTypes.instanceOf(Todos).isRequired
    doCommand:  React.PropTypes.func.isRequired

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

  toggleAll: (event) ->
    @props.doCommand 'set_completed_on_all_todos',
      completed: event.target.checked

  toggle: (todo) ->
    @props.doCommand 'toggle_completed_on_todo', cid: todo.cid

  destroy: (todo) ->
    @props.doCommand 'delete_todo', cid: todo.cid

  clearCompleted: ->
    @props.doCommand 'delete_completed_todos'

  render: ->
    shownTodos = @props.todos.filter (todo) =>
      switch @state.nowShowing
        when ACTIVE_TODOS
          not todo.get('completed')
        when COMPLETED_TODOS
          todo.get('completed')
        else
          true

    todoItems = shownTodos.map (todo) =>
      TodoItem
        key: todo.cid
        todo: todo
        doCommand: @props.doCommand

    counter = (accum, todo) ->
      if todo.get('completed') then accum else accum + 1
    activeTodoCount = @props.todos.reduce counter, 0
    completedCount = @props.todos.length - activeTodoCount

    footer = null
    if activeTodoCount or completedCount
      footer = TodoFooter
        count: activeTodoCount
        completedCount: completedCount
        nowShowing: @state.nowShowing
        doCommand: @props.doCommand

    main = null
    if @props.todos.length
      existing_input_attrs =
        id: 'toggle-all'
        type: 'checkbox'
        onChange: @toggleAll
        checked: activeTodoCount is 0
      main = React.DOM.section(id: 'main',
        React.DOM.input(existing_input_attrs),
        React.DOM.ul(id: 'todo-list', todoItems)
      )

    new_input_attrs =
      ref: 'newField'
      id: 'new-todo'
      placeholder: 'What needs to be done?'
      onKeyDown: @handleNewTodoKeyDown
    React.DOM.div(null,
      React.DOM.div(id: 'header',
        React.DOM.h1(null, 'todos'),
        React.DOM.input(new_input_attrs)
      ),
      main,
      footer
    )

module.exports = TodoApp
