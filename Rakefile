require 'rubygems'
require 'bundler'
Bundler.require

require 'rake'
require 'open-uri'
require 'dotenv/tasks'
require 'logger'

RACK_ENV = ENV['RACK_ENV'] || 'development'
Dotenv.load! ".env.#{RACK_ENV}"

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
  ENV['REMOTE']            = 'true'
  ENV['SELENIUM_HOST']     = 'localhost'
  ENV['SELENIUM_PORT']     = '4444'
  ENV['SELENIUM_BROWSER']  = 'internet explorer'
  ENV['SELENIUM_PLATFORM'] = 'XP'
  ENV['SELENIUM_VERSION']  = ''
  ENV['BROWSER_URL']       = 'http://10.0.2.2:3000/index.html'

  $child_pid = start_selenium_server
  puts 'Wait for VirtualBox grid node to find it...'
  sleep 10
end

task :spec_vm => [:start_selenium_hub_server, :spec, :stop_selenium_server]

task :set_selenium_env_sauce do
  ENV['REMOTE']            = 'true'
  ENV['SELENIUM_HOST']     = 'localhost'
  ENV['SELENIUM_PORT']     = '4445'
  ENV['SELENIUM_BROWSER']  = 'internet explorer'
  ENV['SELENIUM_PLATFORM'] = 'Windows XP'
  ENV['SELENIUM_VERSION']  = '8'
  ENV['BROWSER_URL']       = 'http://localhost:3000/index.html'
  ENV['SAUCE_USER_NAME'] or raise "No ENV[SAUCE_USER_NAME]"
  ENV['SAUCE_API_KEY']   or raise "No ENV[SAUCE_API_KEY]"
end

task :spec_sauce => [:set_selenium_env_sauce, :spec]

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
  app/bower_components/jquery/jquery.js
  app/bower_components/underscore/underscore.js
  app/bower_components/backbone/backbone.js
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
    -t coffeeify
    -o #{task.name}
    --insert-global-vars ''
    -d
  ].join(' ')
  sh command
end

file 'app/concat/bg.png' =>
  'app/bower_components/todomvc-common/bg.png' do |task|
  copy task.prerequisites.first, task.name
end

file 'app/concat' => %w[
  app/concat/all.css
  app/concat/ie8.js
  app/concat/vendor.js
  app/concat/browserified.js
  app/concat/bg.png
]

file 'test/concat/browserified.js' => (
  Dir.glob(['app/*.coffee', 'test/*.coffee']) - ['app/main.coffee']) do |task|
  mkdir_p 'test/concat'
  command = %W[
    node_modules/.bin/browserify
    #{task.prerequisites.join(' ')}
    -t coffeeify
    -o #{task.name}
    --insert-global-vars ''
    -d
  ].join(' ')
  sh command
end

file 'test/concat/vendor.js' => %w[
  app/bower_components/todomvc-common/base.js
  test/react-with-test-utils.js
  app/bower_components/director/build/director.js
  app/bower_components/jquery/jquery.js
  app/bower_components/underscore/underscore.js
  app/bower_components/backbone/backbone.js
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

file 'dist/concat/all.css' => ['app/concat/all.css'] do |task|
  mkdir_p 'dist/concat'
  command = %W[
    cat
    #{task.prerequisites.join(' ')}
    | node_modules/clean-css/bin/cleancss
    -o #{task.name}
  ].join(' ')
  sh command
end

file 'app/bower_components/todomvc-common/base.min.js' =>
     'app/bower_components/todomvc-common/base.js' do |task|
  command = %W[
    node_modules/uglifyify/node_modules/uglify-js/bin/uglifyjs
    #{task.prerequisites.join(' ')}
    > #{task.name}
  ].join(' ')
  sh command
end

file 'dist/concat/ie8.js' => 'app/concat/ie8.js' do |task|
  command = %W[
    node_modules/uglifyify/node_modules/uglify-js/bin/uglifyjs
    #{task.prerequisites.join(' ')}
    > #{task.name}
  ].join(' ')
  sh command
end

file 'dist/concat/vendor.js' => %w[
  app/bower_components/todomvc-common/base.min.js
  app/bower_components/react/react-with-addons.min.js
  app/bower_components/director/build/director.min.js
  app/bower_components/jquery/jquery.min.js
  app/bower_components/underscore/underscore-min.js
  app/newline.js
  app/bower_components/backbone/backbone-min.js
] do |task|
  mkdir_p 'dist/concat'
  command = "cat #{task.prerequisites.join(' ')} > #{task.name}"
  sh command
end

file 'dist/concat/browserified.js' => Dir.glob('app/*.coffee') do |task|
  mkdir_p 'app/concat'
  command = %W[
    node_modules/.bin/browserify
    #{task.prerequisites.join(' ')}
    -t coffeeify
    -t uglifyify
    --insert-global-vars ''
    -d
    | node node_modules/exorcist/bin/exorcist.js
    dist/concat/browserified.js.map
    > #{task.name}
  ].join(' ')
  sh command
end

task :dist => %w[
  app/index.html
  dist/concat/all.css
  dist/concat/ie8.js
  dist/concat/vendor.js
  dist/concat/browserified.js
  app/concat/bg.png
] do
  mkdir_p 'dist'
  cp 'app/index.html', 'dist'

  mkdir_p 'dist/concat'
  cp 'app/concat/bg.png',          'dist/concat/bg.png'
end

task :sauce_connect do
  sauce_user_name = ENV['SAUCE_USER_NAME'] or raise "No ENV[SAUCE_USER_NAME]"
  sauce_api_key   = ENV['SAUCE_API_KEY']   or raise "No ENV[SAUCE_API_KEY]"
  command = %W[
    java
    -jar test/Sauce-Connect/Sauce-Connect.jar
    -d
    #{sauce_user_name}
    #{sauce_api_key}
  ].join(' ')
  sh command
end

namespace :db do
  task :sequel do
    require 'sequel'
    Sequel.extension :migration
    $db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    $db.logger = Logger.new($stdout)
  end

  desc 'Run DB migrations'
  task :migrate, [:version] => :sequel do |t, args|
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run $db, 'db/migrations',
        target: args[:version].to_i
    else
      puts "Migrating to latest"
      Sequel::Migrator.run $db, 'db/migrations'
    end
  end

  desc 'Rollback migration'
  task :rollback => :sequel do
    version = $db[:schema_info].first[:version]
    Sequel::Migrator.apply $db, 'db/migrations', version - 1
  end

  desc 'Dump the database schema'
  task :dump => :sequel do
    sh "sequel -d #{$db.url} > db/schema.rb"
    sh "pg_dump --schema-only #{$db.url} > db/schema.sql"
  end
end
