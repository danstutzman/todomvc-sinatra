TodoApp     = require('../app/TodoApp.coffee')
CommandDoer = require('../app/CommandDoer.coffee')
Todos       = require('../app/Todos.coffee')

# Workaround: require('react') causes firstChild errors
React  = window.React

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
  it 'starts empty but adds one when you type something in', ->
    initialTodos = []
    doer = new CommandDoer()
    todos = new Todos(initialTodos)
    app = TodoApp(todos: todos, doCommand: doer.doCommand)
    doer.app = app
    doer.todos = todos
    div = render(app)

    expect($('#todo-list li').length).toEqual 0

    $('#new-todo').val('added')
    hit_enter_in $('#new-todo')[0]

    expect($('#todo-list li').length).toEqual 1

    div.parentNode.removeChild(div)
