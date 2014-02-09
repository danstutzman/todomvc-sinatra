require 'helper'

BROWSER_URL = ENV['BROWSER_URL'] or raise "No ENV[BROWSER_URL]"

describe 'TodoMVC', type: :feature, js: true do
  before(:each) do
    visit BROWSER_URL
  end

  it 'starts out blank' do
    all('#todo-list li').size.should == 0
  end
  it 'adds a new todo when you type in todo at top and hit Enter' do
    find('#new-todo').set("added2\n")
    all('#todo-list li')[0].find('label').text.should == 'added2'
    all('#todo-list li').size.should == 1
  end
  it 'removes a todo when you hover over it and click X' do
    find('#new-todo').set("added3\n")
    all('#todo-list li')[0].find('label').hover
    all('#todo-list li')[0].find('button.destroy').click
    all('#todo-list li').size.should == 0
  end
  it 'edits a todo when you double-click and type something new' do
    find('#new-todo').set("before\n")
    all('#todo-list li')[0].find('label').double_click
    page.driver.browser.keyboard.send_keys :end, "after\n"
    all('#todo-list li')[0].find('label').text.should == 'beforeafter'
  end
  it 'marks a todo completed when you click completed' do
    find('#new-todo').set("new\n")
    all('#todo-list li.completed').size.should == 0
    all('#todo-list li')[0].find('input.toggle').click
    all('#todo-list li.completed').size.should == 1
  end
  it 'marks a todo uncompleted when you click completed twice' do
    find('#new-todo').set("new\n")
    all('#todo-list li.completed').size.should == 0
    2.times { all('#todo-list li')[0].find('input.toggle').click }
    all('#todo-list li.completed').size.should == 0
  end
  it 'marks all todos completed when you click toggle-all' do
    find('#new-todo').set("1\n")
    find('#new-todo').set("2\n")
    all('#todo-list li')[0].find('input.toggle').click
    all('#todo-list li.completed').size.should == 1
    find('#toggle-all').click
    all('#todo-list li.completed').size.should == 2
  end
  it 'marks all todos uncompleted when you click toggle-all if they\'re all completed' do
    find('#new-todo').set("1\n")
    all('#todo-list li')[0].find('input.toggle').click
    all('#todo-list li.completed').size.should == 1
    find('#toggle-all').click
    all('#todo-list li.completed').size.should == 0
  end

  after(:each) do
    execute_script 'localStorage.clear()'
  end
end
