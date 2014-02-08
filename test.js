var jsdom = require("jsdom").jsdom;
global.document = jsdom("<html><head></head><body>hello world<div id='todoapp'></div></body></html>");
global.window = document.parentWindow;
window.getSelection = function() { return { rangeCount: 0 }};
//console.log(window.document.innerHTML);

global.Router = function() {
  this.init = function() { };
  return this;
}

var React = require('react/addons');
var coffee = require('coffee-script');
coffee.register();
var TodoItem = require('./app/TodoItem.coffee');
var TodoApp = require('./app/TodoApp.coffee');
var Todo = require('./app/Todo.coffee');
var todo = new Todo({title: 'test', completed: false});
var app = TodoApp({initialTodos:[todo]});

//React.renderComponentToString(app, console.log);

//global.$ = require('jquery');
//global.Backbone = { $: require('jquery') };
global.Backbone = require('backbone');
global.Backbone.$ = require('jquery');

React.renderComponent(app, document.getElementById('todoapp'));

console.log(document.getElementById('todoapp').innerHTML);
//app.setState({ todos: [] });
//console.log(document.getElementById('todoapp').innerHTML);

console.log(app.state.todos.models[0].get('completed'));
app.toggleAll({ target: { checked: true } });
console.log(app.state.todos.models[0].get('completed'));

console.log(app.state.todos.models[0].get('completed'));
app.refs.ref0.refs.checkbox.props.onChange();
console.log(app.state.todos.models[0].get('completed'));

app.refs.newField.props.onKeyDown({ keyCode: 13 });
