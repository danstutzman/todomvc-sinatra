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

keydown_in = (node, keyCode, string) ->
  node = node.getDOMNode() if node.getDOMNode
  e = document.createEvent('KeyboardEvent')
  e.initKeyboardEvent("keydown", true, true, null, false, false,
                      false, false, keyCode, string.charCodeAt(0))
  # Hack: see http://stackoverflow.com/questions/10455626/keydown-simulation-in-chrome-fires-normally-but-not-the-correct-key/10520017#10520017
  Object.defineProperty e, 'keyCode', { get: (-> keyCode) }
  Object.defineProperty e, 'which',   { get: (-> string.charCodeAt(0)) }
  node.dispatchEvent e

ENTER_KEY_CODE = 13
ESCAPE_KEY_CODE = 27

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

hash_from_link = (a_element) ->
  a_element = a_element.getDOMNode() if a_element.getDOMNode
  link = a_element.href
  link = link.substring(link.indexOf('#') + 1) # just the part after #

go_to_hash = (hash, done, expectations) ->
  listener1 = ->
    expectations()
    # put things back
    window.removeEventListener 'hashchange', listener1
    window.addEventListener 'hashchange', listener2
    window.location.hash = ''
  listener2 = ->
    window.removeEventListener 'hashchange', listener2
    done()
  window.addEventListener 'hashchange', listener1
  window.location.hash = hash

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
    keydown_in app.refs.newField, ENTER_KEY_CODE, "\n"
    expect(query(app, 'section li').length).toEqual 1

  it 'ignores non-special keydowns in new-todo (just for coverage)', ->
    { todos, app } = setup([])
    keydown_in app.refs.newField, "a".charCodeAt(0), "a"

  it 'ignores Enter when new todo is blank', ->
    { todos, app } = setup([])
    keydown_in app.refs.newField, ENTER_KEY_CODE, "\n"
    expect(query(app, 'section li').length).toEqual 0

  it 'can delete a todo w/ delete button', ->
    { todos, app } = setup([ new Todo(title: 'test', completed: false) ])
    click_on query1(app, 'section li button.destroy')
    expect(query(app, 'section li').length).toEqual 0

  it 'can delete a todo w/ editing to blank', ->
    { todos, app } = setup([ new Todo(title: 'test', completed: false) ])
    dblclick_on query1(app, 'section li label')
    query1(app, 'section li input.edit').value = ''
    trigger_change_in query(app, 'section li input.edit')[0]
    keydown_in query1(app, 'section li input.edit'), ENTER_KEY_CODE, "\n"
    expect(query(app, 'section li').length).toEqual 0

  it 'can start editing a todo', ->
    { todos, app } = setup([ new Todo(title: 'test', completed: false) ])
    dblclick_on query1(app, 'section li label')
    liClasses = query1(app, 'section li').className.split(' ')
    expect(liClasses).toContain('editing')

  it 'can revert editing with Esc key', ->
    { todos, app } = setup([ new Todo(title: 'before', completed: false) ])
    dblclick_on query1(app, 'section li label')
    query1(app, 'section li input.edit').value = 'after'
    trigger_change_in query(app, 'section li input.edit')[0]
    keydown_in query1(app, 'section li input.edit'), ESCAPE_KEY_CODE, "\x1b"
    expect(query1(app, 'section li label').innerHTML).toEqual 'before'
    liClasses = query1(app, 'section li').className.split(' ')
    expect(liClasses).not.toContain('editing')

  it 'can edit a todo', ->
    { todos, app } = setup([ new Todo(title: 'before', completed: false) ])
    dblclick_on query1(app, 'section li label')
    query1(app, 'section li input.edit').value = 'after'
    trigger_change_in query(app, 'section li input.edit')[0]
    keydown_in query1(app, 'section li input.edit'), ENTER_KEY_CODE, "\n"
    expect(query1(app, 'section li label').innerHTML).toEqual 'after'
    liClasses = query1(app, 'section li').className.split(' ')
    expect(liClasses).not.toContain('editing')

  it 'ignores non-special keydowns when editing (just for coverage)', ->
    { todos, app } = setup([ new Todo(title: 'before', completed: false) ])
    dblclick_on query1(app, 'section li label')
    keydown_in query1(app, 'section li input.edit'), "a".charCodeAt(0), "a"

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

  it 'can delete all completed todos', ->
    todo1 = new Todo(title: 'test1', completed: true)
    todo2 = new Todo(title: 'test2', completed: false)
    { todos, app } = setup([todo1, todo2])
    click_on app.refs.footer.refs.clear_completed
    expect(query(app, 'section li').length).toEqual 1

  it 'can filter for all todos', (done) ->
     todo1 = new Todo(title: 'test1', completed: true)
     todo2 = new Todo(title: 'test2', completed: false)
     todo3 = new Todo(title: 'test3', completed: false)
     { todos, app } = setup([todo1, todo2, todo3])
     hash = hash_from_link(app.refs.footer.refs.all)
     go_to_hash hash, done, ->
       expect(query(app, 'section li').length).toEqual 3

  it 'can filter for only non-completed todos', (done) ->
     todo1 = new Todo(title: 'test1', completed: true)
     todo2 = new Todo(title: 'test2', completed: false)
     todo3 = new Todo(title: 'test3', completed: false)
     { todos, app } = setup([todo1, todo2, todo3])
     hash = hash_from_link(app.refs.footer.refs.active)
     go_to_hash hash, done, ->
       expect(query(app, 'section li').length).toEqual 2

  it 'can filter for only completed todos', (done) ->
     todo1 = new Todo(title: 'test1', completed: true)
     todo2 = new Todo(title: 'test2', completed: false)
     todo3 = new Todo(title: 'test3', completed: false)
     { todos, app } = setup([todo1, todo2, todo3])
     hash = hash_from_link(app.refs.footer.refs.completed)
     go_to_hash hash, done, ->
       expect(query(app, 'section li').length).toEqual 1

   afterEach =>
     @div.parentNode.removeChild @div
