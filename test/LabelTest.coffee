render = React.addons.ReactTestUtils.renderIntoDocument
click  = React.addons.ReactTestUtils.Simulate.click

describe 'Label Test', ->
  it 'Check Text Assignment', ->
    label = Label(null, 'Some Text We Need for Test')
    render(label)
    expect(label.refs.p).toBeDefined()
    expect(label.refs.p.props.children).toEqual("Some Text We Need for Test")

  it 'Click', ->
    label = Label(null, 'Some Text We Need for Test')
    render(label)
    click(label.refs.p)
    expect(label.refs.p.props.children).toEqual("Text After Click")
