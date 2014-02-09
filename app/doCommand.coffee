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
module.exports = doCommand
