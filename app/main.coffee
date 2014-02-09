React   = require('react')
TodoApp = require('./TodoApp.coffee')

app = TodoApp({ initialTodos: initialTodos })
React.renderComponent(app, document.getElementById('todoapp'))

React.renderComponent(
  React.DOM.div(null,
    React.DOM.p(null, 'Double-click to edit a todo'),
    React.DOM.p(null, 'Created by', ' ',
      React.DOM.a(href: 'http://github.com/petehunt/', 'petehunt')
    ),
    React.DOM.p(null, 'Part of', ' ',
      React.DOM.a(href: 'http://todomvc.com', 'TodoMVC')
    )
  ),
  document.getElementById('info')
)

window.Todos = require('./Todos.coffee')
window.Todo  = require('./Todo.coffee')
window.app = app
