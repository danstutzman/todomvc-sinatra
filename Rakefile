require 'rubygems'
require 'bundler'
Bundler.setup :default, :development

require 'rake'
require 'open-uri'

$child_pid = nil

require 'rspec/core/rake_task'
desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  #t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
end

task :default => :spec

def start_selenium_server
  command = "java -jar spec/selenium-server-standalone-2.39.0.jar -role hub"
  puts command
  pid = spawn(command, out: :close) # suppress stdout
  puts 'Waiting for selenium server to start'
  while true
    begin
      open('http://localhost:4444/')
      break
    rescue Errno::ECONNREFUSED => e
      # ignore it
    rescue => e
      Process.kill 'INT', pid
      raise
    end
    print '.'
    sleep 1
  end
  pid
end

task :stop_selenium_server do
  Process.kill 'INT', $child_pid
  Process.wait
end

task :start_selenium_hub_server do
  ENV['REMOTE'] = 'true'
  $child_pid = start_selenium_server
  puts 'Wait for VirtualBox grid node to find it...'
  sleep 10
end

task :spec_ie => [:start_selenium_hub_server, :spec, :stop_selenium_server]
