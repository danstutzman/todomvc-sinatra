Todo     = require('../app/Todo.coffee')
TodoItem = require('../app/TodoItem.coffee')

render   = React.addons.ReactTestUtils.renderIntoDocument
Simulate = React.addons.ReactTestUtils.Simulate

describe 'TodoItem', ->
  it 'can be double-clicked', ->
    props =
      todo:      new Todo(title: 'test', completed: false)
      editing:   false
      onEdit:    -> console.log 'edit!'
      onSave:    ->
      onDestroy: ->
      onCancel:  ->
      onToggle:  ->
    item = TodoItem(props, [])
    render(item)
    #Simulate.change(item)
    Simulate.doubleClick(item.refs.label)
    #expect(label.refs.p).toBeDefined()
    #expect(label.refs.p.props.children).toEqual('Some Text We Need for Test')

#  it 'Click', ->
#    label = Label(null, 'Some Text We Need for Test')
#    render(label)
#    click(label.refs.p)
#    expect(label.refs.p.props.children).toEqual('Text After Click')
