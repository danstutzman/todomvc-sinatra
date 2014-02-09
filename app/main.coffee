TodoApp = require('./TodoApp.coffee')
Todos   = require('./Todos.coffee')

todos = new Todos(initialTodos)

doCommand = (name, args) ->
  switch name
    when 'delete_todo'
      todo = todos.get(args['cid'])
      todo.destroy()
      app.setProps todos: todos
    when 'create_todo'
      todos.create title: args['title'], completed: false
      app.setProps todos: todos
    when 'set_completed_on_all_todos'
      todos.each (todo) ->
        todo.set 'completed', args['completed']
      Backbone.sync 'update', todos
      app.setProps todos: todos
    when 'toggle_completed_on_todo'
      todo = todos.get(args['cid'])
      todo.set 'completed', not todo.get('completed')
      todo.save()
      app.setProps todos: todos
    when 'set_title_on_todo'
      todo = todos.get(args['cid'])
      todo.set 'title', args['title']
      todo.save()
      app.setProps todos: todos
    when 'delete_completed_todos'
      toClear = todos.filter (todo) -> todo.get('completed')
      for todo in toClear
        todo.destroy()
      app.setProps todos: todos
    else
      throw new Error("Unknown command name #{name}")

app = TodoApp({ todos: todos, doCommand: doCommand })

React.renderComponent app, document.getElementById('todoapp')

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

