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

task :karma do
  puts system('node_modules/.bin/karma start')
end

task :clean do
  sh 'rm -rf app/concat'
  sh 'rm -rf test/concat'
  sh 'rm -rf dist'
end

file 'app/concat/all.css' => %w[
  app/bower_components/todomvc-common/base.css
] do |task|
  mkdir_p 'app/concat'
  command = "cat #{task.prerequisites.join(' ')} > #{task.name}"
  sh command
end

file 'app/concat/ie8.js' => %w[
  app/bower_components/modernizr/modernizr.js
  app/ie8-clear-local-storage.js
  app/bower_components/es5-shim/es5-shim.js
  app/bower_components/es5-shim/es5-sham.js
  app/bower_components/console-polyfill/index.js
  app/ie8-set-selection-range.js
] do |task|
  mkdir_p 'app/concat'
  command = "cat #{task.prerequisites.join(' ')} > #{task.name}"
  sh command
end

file 'app/concat/vendor.js' => %w[
  app/bower_components/todomvc-common/base.js
  app/bower_components/react/react-with-addons.js
  app/bower_components/director/build/director.js
] do |task|
  mkdir_p 'app/concat'
  command = "cat #{task.prerequisites.join(' ')} > #{task.name}"
  sh command
end

file 'app/concat/browserified.js' => Dir.glob('app/*.coffee') do |task|
  mkdir_p 'app/concat'
  command = %W[
    node_modules/.bin/browserify
    #{task.prerequisites.join(' ')}
    -t coffeeify -o
    #{task.name}
    --insert-global-vars ''
    -d
  ].join(' ')
  sh command
end

file 'app/concat' => %w[
  app/concat/all.css
  app/concat/ie8.js
  app/concat/vendor.js
  app/concat/browserified.js
]

file 'test/concat/browserified.js' => (
  Dir.glob(['app/*.coffee', 'test/*.coffee']) - ['app/main.coffee']) do |task|
  mkdir_p 'test/concat'
  command = %W[
    node_modules/.bin/browserify
    #{task.prerequisites.join(' ')}
    -t coffeeify -o
    #{task.name}
    --insert-global-vars ''
    -d
  ].join(' ')
  sh command
end

file 'test/concat/vendor.js' => %w[
  app/bower_components/todomvc-common/base.js
  test/react-with-test-utils.js
  app/bower_components/director/build/director.js
] do |task|
  mkdir_p 'test/concat'
  command = "cat #{task.prerequisites.join(' ')} > #{task.name}"
  sh command
end

# need to generate app/concat/ie8.js because test/concat/ie8.js symlinks to it
file 'test/concat' => %w[
  app/concat/ie8.js
  test/concat/vendor.js
  test/concat/browserified.js
]

task :dist => %w[app/concat] do
  mkdir_p 'dist'
  cp 'app/index.html', 'dist'

  mkdir_p 'dist/concat'
  cp 'app/concat/all.css',         'dist/concat/all.css'
  cp 'app/concat/browserified.js', 'dist/concat/browserified.js'
  cp 'app/concat/vendor.js',       'dist/concat/vendor.js'
  cp 'app/concat/ie8.js',          'dist/concat/ie8.js'
end
