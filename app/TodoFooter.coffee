type = React.PropTypes

TodoFooter = React.createClass

  propTypes:
    count:          type.number.isRequired
    completedCount: type.number.isRequired
    nowShowing:     type.string.isRequired
    doCommand:      type.func.isRequired

  handleClearCompleted: ->
    @props.doCommand 'delete_completed_todos'

  render: ->

    { a, button, div, li, span, strong, ul } = React.DOM

    selectedIfShowing = (option) =>
      if @props.nowShowing == option then 'selected'

    div
      id: 'footer'
      span
        id: 'todo-count'
        strong {},
          @props.count
        " #{if @props.count == 1 then 'item' else 'items'} left"
      ul
        id: 'filters'
        li {},
          a
            ref: 'all'
            href: '#/'
            className: selectedIfShowing(ALL_TODOS)
            'All'
        ' '
        li {},
          a
            ref: 'active'
            href: '#/active'
            className: selectedIfShowing(ACTIVE_TODOS)
            'Active'
        ' '
        li {},
          a
            ref: 'completed'
            href: '#/completed'
            className: selectedIfShowing(COMPLETED_TODOS)
            'Completed'
      if @props.completedCount > 0
        button
          id: 'clear-completed'
          ref: 'clear_completed'
          onClick: @handleClearCompleted
          "Clear completed (#{@props.completedCount})"

module.exports = TodoFooter
