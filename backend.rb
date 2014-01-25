set :root, File.dirname(__FILE__)
configure(:test) { disable :logging }

get '/' do
  'here'
end
