Utils      = require('./Utils.coffee')
TodoItem   = require('./TodoItem.coffee')
TodoFooter = require('./TodoFooter.coffee')

window.ALL_TODOS       = 'all'
window.ACTIVE_TODOS    = 'active'
window.COMPLETED_TODOS = 'completed'
ENTER_KEY = 13

TodoApp = React.createClass

  displayName: 'TodoApp'

  getInitialState: ->
    todos = Utils.store 'react-todos'
    { todos: todos, nowShowing: ALL_TODOS, editing: null }

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
      newTodo = { id: Utils.uuid(), title: val, completed: false }
      @setState todos: @state.todos.concat([newTodo])
      @refs.newField.getDOMNode().value = ''
    false

  toggleAll: (event) ->
    checked = event.target.checked
    # Note: it's usually better to use immutable data structures since
    # they're easier to reason about and React works very well with them.
    # That's why we use map() and filter() everywhere instead of mutating
    # the array or todo items themselves.
    newTodos = @state.todos.map (todo) ->
      Utils.extend {}, todo, completed: checked
    @setState todos: newTodos

  toggle: (todoToToggle) ->
    newTodos = @state.todos.map (todo) ->
      if todo isnt todoToToggle
        todo
      else
        Utils.extend({}, todo, { completed: not todo.completed })
    @setState todos: newTodos

  destroy: (todo) ->
    newTodos = @state.todos.filter((candidate) -> candidate.id isnt todo.id)
    @setState todos: newTodos

  edit: (todo, callback) ->
    # refer to todoItem.js `handleEdit` for the reasoning behind the callback
    @setState { editing: todo.id }, -> callback()

  save: (todoToSave, text) ->
    newTodos = @state.todos.map (todo) ->
      if todo isnt todoToSave
        todo
      else
        Utils.extend({}, todo, { title: text })
    @setState todos: newTodos, editing: null

  cancel: ->
    @setState editing: null

  clearCompleted: ->
    newTodos = @state.todos.filter((todo) -> not todo.completed)
    @setState todos: newTodos

  componentDidUpdate: ->
    Utils.store 'react-todos', @state.todos

  render: ->
    filter = (todo) ->
      switch @state.nowShowing
        when ACTIVE_TODOS
          not todo.completed
        when COMPLETED_TODOS
          todo.completed
        else
          true
    shownTodos = @state.todos.filter filter, this

    todo_to_item = (todo) ->
      TodoItem
        key: todo.id
        todo: todo
        onToggle: @toggle.bind(this, todo)
        onDestroy: @destroy.bind(this, todo)
        onEdit: @edit.bind(this, todo)
        editing: @state.editing is todo.id
        onSave: @save.bind(this, todo)
        onCancel: @cancel
    todoItems = shownTodos.map todo_to_item, this

    counter = (accum, todo) ->
      if todo.completed then accum else accum + 1
    activeTodoCount = @state.todos.reduce counter, 0
    completedCount = @state.todos.length - activeTodoCount

    footer = null
    if activeTodoCount or completedCount
      footer = TodoFooter
        count: activeTodoCount
        completedCount: completedCount
        nowShowing: @state.nowShowing
        onClearCompleted: @clearCompleted

    main = null
    if @state.todos.length
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
      React.DOM.header(id: 'header',
        React.DOM.h1(null, 'todos'),
        React.DOM.input(new_input_attrs)
      )
      main,
      footer
    )

module.exports = TodoApp
