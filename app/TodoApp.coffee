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
    editing: null

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
    false

  toggleAll: (event) ->
    @props.doCommand 'set_completed_on_all_todos',
      completed: event.target.checked

  toggle: (todo) ->
    @props.doCommand 'toggle_completed_on_todo', cid: todo.cid

  destroy: (todo) ->
    @props.doCommand 'delete_todo', cid: todo.cid

  edit: (todo, callback) ->
    # refer to todoItem.js `handleEdit` for the reasoning behind the callback
    @setState { editing: todo.cid }, -> callback()

  # warning: may be called twice in a row
  save: (todo, text) ->
    if text != todo.get('title')
      @props.doCommand 'set_title_on_todo', cid: todo.cid, title: text
    @setState editing: null

  cancel: ->
    @setState editing: null

  clearCompleted: ->
    @props.doCommand 'delete_completed_todos'

  render: ->
    filter = (todo) ->
      switch @state.nowShowing
        when ACTIVE_TODOS
          not todo.get('completed')
        when COMPLETED_TODOS
          todo.get('completed')
        else
          true
    shownTodos = @props.todos.filter filter, this

    todo_to_item = (todo) ->
      TodoItem
        key: todo.cid
        todo: todo
        onToggle: @toggle.bind(this, todo)
        onDestroy: @destroy.bind(this, todo)
        onEdit: @edit.bind(this, todo)
        editing: @state.editing is todo.cid
        onSave: @save.bind(this, todo)
        onCancel: @cancel
        doCommand: @props.doCommand
    todoItems = shownTodos.map todo_to_item, this

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
        onClearCompleted: @clearCompleted

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
