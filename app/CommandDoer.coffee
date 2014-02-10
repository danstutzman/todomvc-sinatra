Backbone = require('backbone')

class CommandDoer
  constructor: (todos) ->
    @todos = todos
  doCommand: (name, args) =>
    switch name
      when 'delete_todo'
        todo = @todos.get(args['cid'])
        todo.destroy()
      when 'create_todo'
        @todos.create title: args['title'], completed: false
      when 'set_completed_on_all_todos'
        @todos.each (todo) ->
          todo.set 'completed', args['completed']
        Backbone.sync 'update', @todos
      when 'toggle_completed_on_todo'
        todo = @todos.get(args['cid'])
        todo.set 'completed', not todo.get('completed')
        todo.save()
      when 'set_title_on_todo'
        todo = @todos.get(args['cid'])
        todo.set 'title', args['title']
        todo.save()
      when 'delete_completed_todos'
        toClear = @todos.filter (todo) -> todo.get('completed')
        for todo in toClear
          todo.destroy()
      else
        throw new Error("Unknown command name #{name}")
  
module.exports = CommandDoer
