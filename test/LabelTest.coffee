React  = require('react')
Label  = require('../app/Label.coffee')

body   = window.document.getElementsByTagName('body')[0]

render = (instance) ->
  div = document.createElement('div')
  body.appendChild(div)
  React.renderComponent(instance, div)

click_on = (node) ->
  node = node.getDOMNode() if node.getDOMNode
  node.dispatchEvent(new MouseEvent('click', { bubbles: true }))

describe 'Label Test', ->
  # if IE8, avoid "HTML Parsing Error: Unable to modify the parent container
  # element before the child element is closed (KB927917)" by waiting
  if document.attachEvent
    beforeEach ->
      if defined?(runs)
        runs ->
          document.attachEvent 'onreadystatechange', ->
            if document.readyState == 'complete'
              document.detachEvent 'onreadystatechange', arguments.callee
        waits()

  it 'Check Text Assignment', ->
    label = Label(null, 'Some Text We Need for Test')
    render(label)
    expect(label.refs.p).toBeDefined()
    expect(label.refs.p.props.children).toEqual('Some Text We Need for Test')

  it 'Click', ->
    label = Label(null, 'Some Text We Need for Test')
    render(label)
    click_on(label.refs.p)
    expect(label.refs.p.props.children).toEqual('Text After Click')
