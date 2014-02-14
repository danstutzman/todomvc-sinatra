React       = require('react')
TodoApp     = require('../app/TodoApp.coffee')
CommandDoer = require('../app/CommandDoer.coffee')

body   = window.document.getElementsByTagName('body')[0]

render = (instance) ->
  div = document.createElement('div')
  body.appendChild(div)
  React.renderComponent(instance, div)
  div

click_on = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  if node.fireEvent # if IE8
    if node.nodeName == 'INPUT' && node.type == 'checkbox'
      node.checked = not node.checked
    e = document.createEventObject()
    node.fireEvent 'onclick', e
  else
    node.dispatchEvent(new MouseEvent('click', { bubbles: true }))

dblclick_on = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  if node.fireEvent # if IE8
    e = document.createEventObject()
    node.fireEvent 'ondblclick', e
  else
    node.dispatchEvent(new MouseEvent('dblclick', { bubbles: true }))

keydown_in = (node, keyCode, string) ->
  node = node.getDOMNode() if node.getDOMNode
  if node.fireEvent # if IE8
    e = document.createEventObject()
    e.bubbles = true
    e.cancelable = true
    e.view = window
    e.keyCode = keyCode
    e.which = keyCode
    e.charCode = string.charCodeAt(0)
    node.fireEvent 'onkeydown', e
  else
    e = document.createEvent 'Events'
    e.initEvent 'keydown', true, true
    e.keyCode = keyCode
    e.which = keyCode
    e.charCode = string.charCodeAt(0)
    node.dispatchEvent e

ENTER_KEY_CODE = 13
ESCAPE_KEY_CODE = 27

trigger_change_in = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  if node.fireEvent # if IE8 (which React does funny change listening for)
    oldvalue = node.value         # save old value of value
    node.value = 'something else' # change it so React updates its cache
    delete node.value             # remove React's handler
    node.value = oldvalue         # change it back so React fires change
  else
    e = new Event('input', { bubbles: true })
    node.dispatchEvent e

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

describe 'TodoApp', ->
  setup = (initialTodos) =>
    app = TodoApp
      todos: _.map(initialTodos, (todo, cid) -> _.extend(todo, cid: cid))
      nowShowing: 'all'
      doCommand: (name, args) ->
        oldTodos = app.props.todos
        newTodos = CommandDoer.doCommand(name, args, oldTodos)
        app.setProps todos: newTodos
    @div = render(app)
    app

  it 'can start empty', ->
    app = setup([])
    expect(query(app, 'div.main li').length).toEqual 0

  it 'can start with one todo', ->
    app = setup([title: 'test', completed: false])
    expect(query(app, 'div.section li').length).toEqual 1

  it 'can add a todo', ->
    app = setup([])
    app.refs.newField.getDOMNode().value = 'added'
    keydown_in app.refs.newField, ENTER_KEY_CODE, "\n"
    expect(query(app, 'div.section li').length).toEqual 1

  it 'ignores non-special keydowns in new-todo (just for coverage)', ->
    app = setup([])
    keydown_in app.refs.newField, "a".charCodeAt(0), "a"

  it 'ignores Enter when new todo is blank', ->
    app = setup([])
    keydown_in app.refs.newField, ENTER_KEY_CODE, "\n"
    expect(query(app, 'div.section li').length).toEqual 0

  it 'can delete a todo w/ delete button', ->
    app = setup([title: 'test', completed: false])
    click_on query1(app, 'div.section li button.destroy')
    expect(query(app, 'div.section li').length).toEqual 0

  it 'can delete a todo w/ editing to blank', ->
    app = setup([title: 'test', completed: false])
    dblclick_on query1(app, 'div.section li label')
    query1(app, 'div.section li input.edit').value = ''
    trigger_change_in query(app, 'div.section li input.edit')[0]
    keydown_in query1(app, 'div.section li input.edit'), ENTER_KEY_CODE, "\n"
    expect(query(app, 'div.section li').length).toEqual 0

  it 'can start editing a todo', ->
    app = setup([title: 'test', completed: false])
    dblclick_on query1(app, 'div.section li label')
    liClasses = query1(app, 'div.section li').className.split(' ')
    expect(liClasses).toContain('editing')

  it 'can revert editing with Esc key', ->
    app = setup([title: 'before', completed: false])
    dblclick_on query1(app, 'div.section li label')
    query1(app, 'div.section li input.edit').value = 'after'
    trigger_change_in query(app, 'div.section li input.edit')[0]
    keydown_in query1(app, 'div.section li input.edit'), ESCAPE_KEY_CODE, "\x1b"
    expect(query1(app, 'div.section li label').innerHTML).toEqual 'before'
    liClasses = query1(app, 'div.section li').className.split(' ')
    expect(liClasses).not.toContain('editing')

  it 'can edit a todo', ->
    todo1 = title: 'before', completed: false
    todo2 = title: 'ignoreme', completed: false
    app = setup([todo1, todo2])
    dblclick_on query(app, 'div.section li label')[0]
    query(app, 'div.section li input.edit')[0].value = 'after'
    trigger_change_in query(app, 'div.section li input.edit')[0]
    keydown_in query(app, 'div.section li input.edit')[0], ENTER_KEY_CODE, "\n"
    expect(query(app, 'div.section li label')[0].innerHTML).toEqual 'after'
    liClasses = query(app, 'div.section li')[0].className.split(' ')
    expect(liClasses).not.toContain('editing')

  it 'can leave a todo unedited (for coverage)', ->
    app = setup([title: 'unchanged', completed: false])
    dblclick_on query1(app, 'div.section li label')
    trigger_change_in query(app, 'div.section li input.edit')[0]
    keydown_in query1(app, 'div.section li input.edit'), ENTER_KEY_CODE, "\n"

  it 'ignores non-special keydowns when editing (just for coverage)', ->
    app = setup([title: 'before', completed: false])
    dblclick_on query1(app, 'div.section li label')
    keydown_in query1(app, 'div.section li input.edit'), "a".charCodeAt(0), "a"

  it 'can mark a todo completed', ->
    todo1 = title: 'test1', completed: false
    todo2 = title: 'test2', completed: false
    app = setup([todo1, todo2])
    click_on query(app, 'div.section li input[type=checkbox]')[0]
    expect(query(app, 'div.section li.completed').length).toEqual 1

  it 'can mark a todo not completed', ->
    app = setup([title: 'test', completed: true])
    click_on query1(app, 'div.section li input[type=checkbox]')
    expect(query(app, 'div.section li.completed').length).toEqual 0

  it 'can mark all todos completed (starting w/ uncompleted)', ->
    todo1 = title: 'test1', completed: false
    todo2 = title: 'test2', completed: false
    app = setup([todo1, todo2])
    click_on app.refs.toggle_all
    expect(query(app, 'div.section li.completed').length).toEqual 2

  it 'can mark all todos completed (starting w/ 1 completed)', ->
    todo1 = title: 'test1', completed: true
    todo2 = title: 'test2', completed: false
    app = setup([todo1, todo2])
    click_on app.refs.toggle_all
    expect(query(app, 'div.section li.completed').length).toEqual 2

  it 'can mark all todos uncompleted', ->
    todo1 = title: 'test1', completed: true
    todo2 = title: 'test2', completed: true
    app = setup([todo1, todo2])
    click_on app.refs.toggle_all
    expect(query(app, 'section li.completed').length).toEqual 0

  it 'can delete all completed todos', ->
    todo1 = title: 'test1', completed: true
    todo2 = title: 'test2', completed: false
    app = setup([todo1, todo2])
    click_on app.refs.footer.refs.clear_completed
    expect(query(app, 'div.section li').length).toEqual 1

  it 'can filter for all todos', ->
     todo1 = title: 'test1', completed: true
     todo2 = title: 'test2', completed: false
     todo3 = title: 'test3', completed: false
     app = setup([todo1, todo2, todo3])
     app.setProps nowShowing: 'all'
     expect(query(app, 'div.section li').length).toEqual 3

  it 'can filter for only non-completed todos', ->
     todo1 = title: 'test1', completed: true
     todo2 = title: 'test2', completed: false
     todo3 = title: 'test3', completed: false
     app = setup([todo1, todo2, todo3])
     app.setProps nowShowing: 'active'
     expect(query(app, 'div.section li').length).toEqual 2

  it 'can filter for only completed todos', ->
     todo1 = title: 'test1', completed: true
     todo2 = title: 'test2', completed: false
     todo3 = title: 'test3', completed: false
     app = setup([todo1, todo2, todo3])
     app.setProps nowShowing: 'completed'
     expect(query(app, 'div.section li').length).toEqual 1

   afterEach =>
     @div.parentNode.removeChild @div
