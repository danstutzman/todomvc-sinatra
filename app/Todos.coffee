Todo     = require('./Todo.coffee')

Todos = Backbone.Collection.extend
  model: Todo
  comparator: 'id'

module.exports = Todos
