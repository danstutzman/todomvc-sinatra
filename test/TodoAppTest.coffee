React       = require('react')
TodoApp     = require('../app/TodoApp.coffee')
CommandDoer = require('../app/CommandDoer.coffee')
Todo        = require('../app/Todo.coffee')
Todos       = require('../app/Todos.coffee')

body   = window.document.getElementsByTagName('body')[0]

render = (instance) ->
  div = document.createElement('div')
  body.appendChild(div)
  React.renderComponent(instance, div)
  div

click_on = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  node.dispatchEvent(new MouseEvent('click', { bubbles: true }))

dblclick_on = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  node.dispatchEvent(new MouseEvent('dblclick', { bubbles: true }))

hit_enter_in = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  e = document.createEvent('KeyboardEvent')
  e.initKeyboardEvent("keydown", true, true, null, false, false,
                      false, false, 13, "\n".charCodeAt(0))
  # Hack: see http://stackoverflow.com/questions/10455626/keydown-simulation-in-chrome-fires-normally-but-not-the-correct-key/10520017#10520017
  Object.defineProperty e, 'keyCode', { get: (-> 13) }
  Object.defineProperty e, 'which',   { get: (-> 13) }
  node.dispatchEvent e

trigger_change_in = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  e = new Event('input', { bubbles: true })
  node.dispatchEvent(e)

query = (node, selector) ->
  node = node.getDOMNode() if node.getDOMNode
  node.querySelectorAll(selector)

query1 = (node, selector) ->
  results = query(node, selector)
  if results.length == 0
    throw new Error("Expected 1 result from #{selector} but got 0")
  else if results.length > 1
    throw new Error(
      "Expected 1 result from #{selector} but got #{results.length}")
  else
    results[0]

describe 'TodoApp', ->

  setup = (initialTodos) =>
    todos = new Todos(initialTodos)
    doer = new CommandDoer(todos)
    app = TodoApp(todos: todos, doCommand: doer.doCommand)
    todos.on 'add destroy change', -> app.setProps todos: todos
    @div = render(app)
    { todos, app }

  it 'can start empty', ->
    { todos, app } = setup([])
    expect(query(app, 'section li').length).toEqual 0

  it 'can start with one todo', ->
    { todos, app } = setup([ new Todo(title: 'test', completed: false) ])
    expect(query(app, 'section li').length).toEqual 1

  it 'can add a todo', ->
    { todos, app } = setup([])
    app.refs.newField.getDOMNode().value = 'added'
    hit_enter_in app.refs.newField
    expect(query(app, 'section li').length).toEqual 1

  it 'can delete a todo', ->
    { todos, app } = setup([ new Todo(title: 'test', completed: false) ])
    click_on query1(app, 'section li button.destroy')
    expect(query(app, 'section li').length).toEqual 0

  it 'can edit a todo', ->
    { todos, app } = setup([ new Todo(title: 'before', completed: false) ])
    dblclick_on query1(app, 'section li label')
    query1(app, 'section li input.edit').value = 'after'
    trigger_change_in query(app, 'section li input.edit')[0]
    hit_enter_in query1(app, 'section li input.edit')
    expect(query1(app, 'section li label').innerHTML).toEqual 'after'

  it 'can mark a todo completed', ->
    { todos, app } = setup([ new Todo(title: 'test', completed: false) ])
    click_on query1(app, 'section li input[type=checkbox')
    expect(query(app, 'section li.completed').length).toEqual 1

  it 'can mark a todo not completed', ->
    { todos, app } = setup([ new Todo(title: 'test', completed: true) ])
    click_on query1(app, 'section li input[type=checkbox')
    expect(query(app, 'section li.completed').length).toEqual 0

  it 'can mark all todos completed (starting w/ uncompleted)', ->
    todo1 = new Todo(title: 'test1', completed: false)
    todo2 = new Todo(title: 'test2', completed: false)
    { todos, app } = setup([todo1, todo2])
    click_on app.refs.toggle_all
    expect(query(app, 'section li.completed').length).toEqual 2

  it 'can mark all todos completed (starting w/ 1 completed)', ->
    todo1 = new Todo(title: 'test1', completed: true)
    todo2 = new Todo(title: 'test2', completed: false)
    { todos, app } = setup([todo1, todo2])
    click_on app.refs.toggle_all
    expect(query(app, 'section li.completed').length).toEqual 2

  it 'can mark all todos uncompleted', ->
    todo1 = new Todo(title: 'test1', completed: true)
    todo2 = new Todo(title: 'test2', completed: true)
    { todos, app } = setup([todo1, todo2])
    click_on app.refs.toggle_all
    expect(query(app, 'section li.completed').length).toEqual 0

  afterEach =>
    @div.parentNode.removeChild @div
