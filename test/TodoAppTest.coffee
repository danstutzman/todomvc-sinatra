React       = require('react')
TodoWrapper = require('../app/TodoWrapper.coffee')

body   = window.document.getElementsByTagName('body')[0]

click_on = (node) ->
  if node.fireEvent # if IE8
    if node.nodeName == 'INPUT' && node.type == 'checkbox'
      node.checked = not node.checked
    e = document.createEventObject()
    node.fireEvent 'onclick', e
  else
    node.dispatchEvent(new MouseEvent('click', { bubbles: true }))

dblclick_on = (node) ->
  if node.fireEvent # if IE8
    e = document.createEventObject()
    node.fireEvent 'ondblclick', e
  else
    node.dispatchEvent(new MouseEvent('dblclick', { bubbles: true }))

keydown_in = (node, keyCode, string) ->
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

hash_from_link = (a_element) ->
  a_element = a_element.getDOMNode() if a_element.getDOMNode
  link = a_element.href
  link = link.substring(link.indexOf('#') + 1) # just the part after #

go_to_hash = (hash, done, expectations) ->
  if window.attachEvent # if IE8
    listener1 = ->
      expectations()
      # put things back
      window.detachEvent 'onhashchange', listener1
      window.attachEvent 'onhashchange', listener2
      window.location.hash = ''
    listener2 = ->
      window.detachEvent 'onhashchange', listener2
      done()
    window.attachEvent 'onhashchange', listener1
    window.location.hash = hash
  else
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

find = (node, selector, i) =>
  if i is undefined
    node.querySelectorAll(selector)
  else
    results = node.querySelectorAll(selector)
    if results.length == 0
      throw new Error("No results from #{selector}")
    results[i]

find1 = (node, selector) =>
  results = find(node, selector)

describe 'TodoApp', ->
  @div            = null
  @li             = (i) => find @div, 'div.section li', i
  @new            = (i) => find @div, '#new-todo', i
  @delete         = (i) => find @div, 'div.section li button.destroy', i
  @edit           = (i) => find @div, 'div.section li input.edit', i
  @label          = (i) => find @div, 'div.section li label', i
  @completed      = (i) => find @div, 'div.section li input[type=checkbox]', i
  @liCompleted    = (i) => find @div, 'div.section li.completed', i
  @toggleAll      = (i) => find @div, '#toggle-all', i
  @clearCompleted = (i) => find @div, '#clear-completed', i
  @footerLink     = (i) => find @div, '#footer li a', i

  beforeEach ->
    jasmine.addMatchers
      isLength: ->
        compare: (actual, expected) ->
          if actual.length == expected
            pass: true
            message: "#{actual} are length #{expected}"
          else
            pass: false
            message: "#{actual} are length #{actual.length} not #{expected}"

  setup = (initialTodos) =>
    @div = document.createElement('div')
    body.appendChild(@div)
    new TodoWrapper(initialTodos, @div).run()

  it 'can start empty', =>
    setup []
    expect(@li()).isLength 1 # intentionally break build

  it 'can start with one todo', =>
    setup [title: 'test', completed: false]
    expect(@li()).isLength 1

  it 'can add a todo', =>
    setup []
    @new(0).value = 'added'
    keydown_in @new(0), ENTER_KEY_CODE, "\n"
    expect(@li()).isLength 1

  it 'ignores non-special keydowns in new-todo (just for coverage)', =>
    setup []
    keydown_in @new(0), 'a'.charCodeAt(0), 'a'

  it 'ignores Enter when new todo is blank', =>
    setup []
    keydown_in @new(0), ENTER_KEY_CODE, "\n"
    expect(@li()).isLength 0

  it 'can delete a todo w/ delete button', =>
    setup [title: 'test', completed: false]
    click_on @delete(0)
    expect(@li()).isLength 0

  it 'can delete a todo w/ editing to blank', =>
    setup [title: 'test', completed: false]
    dblclick_on @label(0)
    @edit(0).value = ''
    trigger_change_in @edit(0)
    keydown_in @edit(0), ENTER_KEY_CODE, "\n"
    expect(@li()).isLength 0

  it 'can start editing a todo', =>
    setup [title: 'test', completed: false]
    dblclick_on @label(0)
    expect(@li(0).className.split(' ')).toContain 'editing'

  it 'can revert editing with Esc key', =>
    setup [title: 'before', completed: false]
    dblclick_on @label(0)
    @edit(0).value = 'after'
    trigger_change_in @edit(0)
    keydown_in @edit(0), ESCAPE_KEY_CODE, "\x1b"
    expect(@label(0).innerHTML).toEqual 'before'
    expect(@li(0).className.split(' ')).not.toContain 'editing'

  it 'can edit a todo', =>
    setup [{title: 'before',   completed: false},
           {title: 'ignoreme', completed: false}]
    dblclick_on @label(0)
    @edit(0).value = 'after'
    trigger_change_in @edit(0)
    keydown_in @edit(0), ENTER_KEY_CODE, "\n"
    expect(@label(0).innerHTML).toEqual 'after'
    expect(@li(0).className.split(' ')).not.toContain 'editing'

  it 'can leave a todo unedited (for coverage)', =>
    setup [title: 'unchanged', completed: false]
    dblclick_on @label(0)
    trigger_change_in @edit(0)
    keydown_in @edit(0), ENTER_KEY_CODE, "\n"

  it 'ignores non-special keydowns when editing (just for coverage)', =>
    setup [title: 'before', completed: false]
    dblclick_on @label(0)
    keydown_in @edit(0), "a".charCodeAt(0), "a"

  it 'can mark a todo completed', =>
    setup [{title: 'test1', completed: false},
           {title: 'test2', completed: false}]
    click_on @completed(0)
    expect(@liCompleted()).isLength 1

  it 'can mark a todo not completed', =>
    setup [title: 'test', completed: true]
    click_on @completed(0)
    expect(@liCompleted()).isLength 0

  it 'can mark all todos completed (starting w/ uncompleted)', =>
    setup [{title: 'test1', completed: false},
           {title: 'test2', completed: false}]
    click_on @toggleAll(0)
    expect(@liCompleted()).isLength 2

  it 'can mark all todos completed (starting w/ 1 completed)', =>
    setup [{title: 'test1', completed: true},
           {title: 'test2', completed: false}]
    click_on @toggleAll(0)
    expect(@liCompleted()).isLength 2

  it 'can mark all todos uncompleted', =>
    setup [{title: 'test1', completed: true},
           {title: 'test2', completed: true}]
    click_on @toggleAll(0)
    expect(@liCompleted()).isLength 0

  it 'can delete all completed todos', =>
    setup [{title: 'test1', completed: true},
           {title: 'test2', completed: false}]
    click_on @clearCompleted(0)
    expect(@li()).isLength 1

  it 'can filter for all todos', (done) =>
    setup [{title: 'test1', completed: true},
           {title: 'test2', completed: false},
           {title: 'test3', completed: false}]
    go_to_hash hash_from_link(@footerLink(0)), done, =>
      expect(@li()).isLength 3

  it 'can filter for only non-completed todos', (done) =>
    setup [{title: 'test1', completed: true},
           {title: 'test2', completed: false},
           {title: 'test3', completed: false}]
    go_to_hash hash_from_link(@footerLink(1)), done, =>
      expect(@li()).isLength 2

  it 'can filter for only completed todos', (done) =>
    setup [{title: 'test1', completed: true},
           {title: 'test2', completed: false},
           {title: 'test3', completed: false}]
    go_to_hash hash_from_link(@footerLink(2)), done, =>
      expect(@li()).isLength 1

  afterEach =>
    @div.parentNode.removeChild @div
