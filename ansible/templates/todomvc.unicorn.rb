APP_ROOT  = ENV["RAILS_ROOT"]
RAILS_ENV = ENV["RAILS_ENV"]

#pid         "#{APP_ROOT}/tmp/pids/unicorn.pid"
pid         "/home/deployer/todomvc-sinatra/shared/unicorn.pid"
#listen      "#{APP_ROOT}/tmp/sockets/unicorn.sock"
listen      "/home/deployer/todomvc-sinatra/shared/unicorn.sock"
#stderr_path "#{APP_ROOT}/log/unicorn_error.log"
stderr_path "/home/deployer/todomvc-sinatra/shared/unicorn_error.log"

working_directory "#{APP_ROOT}"
worker_processes 1
