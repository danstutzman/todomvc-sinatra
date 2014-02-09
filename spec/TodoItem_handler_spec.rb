require 'helper'
require 'json'
require 'pry'

BROWSER_URL = ENV['BROWSER_URL'] or raise "No ENV[BROWSER_URL]"

def expect_cmd(*args)
  expect_cmds args
end

def expect_cmds(*expected)
  # change symbols to strings
  expected = JSON.parse(JSON.generate(expected))

  json_values = all('#commands')[0].value.split("\n")
  if json_values == []
    [].should == expected
  else
    json_values.map { |val| JSON.parse(val) }.should == expected
  end
end

describe 'TodoItem', type: :feature, js: true do
  before(:each) do
    visit BROWSER_URL
  end

  it 'toggles completed when checkbox clicks' do
    find('#todo-item-here li input[type=checkbox]').click
    expect_cmd 'toggle_completed_on_todo', cid: 'c1'
  end

  it 'changes the todo when double-clicked and text entered' do
    find('#todo-item-here li label').double_click
    find('#todo-item-here input.edit').native.send_keys "\b\b\b\bnew\n"
    expect_cmd 'set_title_on_todo', cid: 'c1', title: 'new'
  end

  it 'deletes the todo when double-clicked and no text entered' do
    find('#todo-item-here li label').double_click
    find('#todo-item-here input.edit').native.send_keys "\b\b\b\b\n"
    expect_cmd 'delete_todo', cid: 'c1'
  end

end
