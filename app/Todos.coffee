Todo     = require('./Todo.coffee')

Todos = Backbone.Collection.extend
  model: Todo
  url: '/todos'
  comparator: 'id'

module.exports = Todos
