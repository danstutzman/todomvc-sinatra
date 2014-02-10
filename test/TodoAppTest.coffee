React       = require('react')
TodoApp     = require('../app/TodoApp.coffee')
CommandDoer = require('../app/CommandDoer.coffee')
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

hit_enter_in = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  e = document.createEvent('KeyboardEvent')
  e.initKeyboardEvent("keydown", true, true, null, false, false,
                      false, false, 13, "\n".charCodeAt(0))
  # Hack: see http://stackoverflow.com/questions/10455626/keydown-simulation-in-chrome-fires-normally-but-not-the-correct-key/10520017#10520017
  Object.defineProperty e, 'keyCode', { get: (-> 13) }
  Object.defineProperty e, 'which',   { get: (-> 13) }
  node.dispatchEvent e

describe 'TodoApp', ->
  setup = (initialTodos) =>
    todos = new Todos(initialTodos)
    doer = new CommandDoer(todos)
    app = TodoApp(todos: todos, doCommand: doer.doCommand)
    todos.on 'add destroy change', -> app.setProps todos: todos
    @div = render(app)
    { todos, app }

  it 'starts empty but adds one when you type something in', ->
    { todos, app } = setup([])

    expect($('#todo-list li').length).toEqual 0

    $('#new-todo').val('added')
    hit_enter_in $('#new-todo')[0]

    expect($('#todo-list li').length).toEqual 1

  afterEach =>
    @div.parentNode.removeChild @div
