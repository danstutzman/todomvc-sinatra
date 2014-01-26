render = React.addons.ReactTestUtils.renderIntoDocument
click  = React.addons.ReactTestUtils.Simulate.click

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
    click(label.refs.p)
    expect(label.refs.p.props.children).toEqual('Text After Click')
