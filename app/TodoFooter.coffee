#React = require('react')
Utils = require('./Utils.coffee')

ALL_TODOS       = 'all'
ACTIVE_TODOS    = 'active'
COMPLETED_TODOS = 'completed'

TodoFooter = React.createClass

  render: ->
    activeTodoWord = Utils.pluralize(@props.count, 'item')

    clear_button = null
    if @props.completedCount > 0
      attrs = { id: "clear-completed", onClick: @props.onClearCompleted }
      clear_button = React.DOM.button(attrs,
        '', 'Clear completed (', @props.completedCount, ')', ''
      )

    show = { ALL_TODOS: '', ACTIVE_TODOS: '', COMPLETED_TODOS: '' }
    show[@props.nowShowing] = 'selected'

    React.DOM.footer(id: 'footer',
      React.DOM.span(id: 'todo-count',
        React.DOM.strong(null, @props.count), ' ',
        activeTodoWord, ' ', 'left', ''
      ),
      React.DOM.ul(id: 'filters',
        React.DOM.li(null,
          React.DOM.a(href: '#/', className: show[ALL_TODOS], "All")
        ), ' ',
        React.DOM.li(null,
          React.DOM.a(href: '#/active', className: show[ACTIVE_TODOS], 'Active')
        ), ' ',
        React.DOM.li(null,
          React.DOM.a(
            { href: '#/completed', className: show[COMPLETED_TODOS] },
            'Completed'
          )
        )
      ),
      clear_button
    )

module.exports = TodoFooter
