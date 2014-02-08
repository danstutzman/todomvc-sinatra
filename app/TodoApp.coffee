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

  getInitialState: ->
    { todos: new Todos(), nowShowing: ALL_TODOS, editing: null }

  componentDidMount: ->
    router = Router
      '/':          @setState.bind(this, nowShowing: ALL_TODOS)
      '/active':    @setState.bind(this, nowShowing: ACTIVE_TODOS)
      '/completed': @setState.bind(this, nowShowing: COMPLETED_TODOS)
    router.init()
    @state.todos.on 'add remove change', =>
      @setState todos: @state.todos
    @state.todos.fetch()
    @refs.newField.getDOMNode().focus()

  handleNewTodoKeyDown: (event) ->
    return if event.keyCode != ENTER_KEY
    val = @refs.newField.getDOMNode().value.trim()
    if val
      @state.todos.create(title: val, completed: false)
      @refs.newField.getDOMNode().value = ''
    false

  toggleAll: (event) ->
    checked = event.target.checked
    @state.todos.each (todo) ->
      todo.set 'completed', checked
    Backbone.sync 'update', @state.todos

  toggle: (todo) ->
    todo.set 'completed', not todo.get('completed')
    todo.save()

  destroy: (todo) ->
    todo.destroy()

  edit: (todo, callback) ->
    # refer to todoItem.js `handleEdit` for the reasoning behind the callback
    @setState { editing: todo.cid }, -> callback()

  # warning: may be called twice in a row
  save: (todo, text) ->
    todo.set 'title', text
    if todo.changedAttributes()
      todo.save()
    @setState editing: null

  cancel: ->
    @setState editing: null

  clearCompleted: ->
    toClear = @state.todos.filter (todo) -> todo.get('completed')
    for todo in toClear
      todo.destroy()

  render: ->
    filter = (todo) ->
      switch @state.nowShowing
        when ACTIVE_TODOS
          not todo.get('completed')
        when COMPLETED_TODOS
          todo.get('completed')
        else
          true
    shownTodos = @state.todos.filter filter, this

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
    todoItems = shownTodos.map todo_to_item, this

    counter = (accum, todo) ->
      if todo.get('completed') then accum else accum + 1
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
      React.DOM.div(id: 'header',
        React.DOM.h1(null, 'todos'),
        React.DOM.input(new_input_attrs)
      ),
      main,
      footer
    )

module.exports = TodoApp
