React    = require('react')
Todo     = require('../app/Todo.coffee')
Todos    = require('../app/Todos.coffee')
TodoItem = require('../app/TodoItem.coffee')
TodoApp  = require('../app/TodoApp.coffee')

# helpers
render = (instance) ->
  div = document.createElement('div')
  document.documentElement.appendChild(div)
  React.renderComponent(instance, div)
click_on = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  node.dispatchEvent(new MouseEvent('click', { bubbles: true }))
dblclick_on = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  node.dispatchEvent(new MouseEvent('dblclick', { bubbles: true }))
expect_focus_on = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  expect(document.activeElement).toEqual(node)

describe 'TodoApp', ->

  it 'is initialized correctly (no todos)', ->
    app = TodoApp({ initialTodos: [] })
    render app

    { todos, nowShowing, editing } = app.state
    expect(todos.models).toEqual([])
    expect(nowShowing).toEqual('all')
    expect(editing).toEqual(null)

  it 'can toggle all', ->
    todo = new Todo(title: 'test', completed: false)
    app = TodoApp({ initialTodos: [todo] }, null)
    render app

    { todos, nowShowing, editing } = app.state
    expect(todos.models).toEqual([todo])
    expect(nowShowing).toEqual('all')
    expect(editing).toEqual(null)
    expect(todos.models[0].get('completed')).toEqual(false)

    click_on app.refs.toggle_all

    expect(todos.models[0].get('completed')).toEqual(true)

describe 'TodoItem', ->
  it 'can be double-clicked', ->
    props =
      todo:      new Todo(title: 'test', completed: false)
      editing:   false
      onEdit:    (cb) -> cb()
      onSave:    ->
      onDestroy: ->
      onCancel:  ->
      onToggle:  ->
    item = TodoItem(props, [])
    render item
    dblclick_on item.refs.label
    expect_focus_on item.refs.editField
