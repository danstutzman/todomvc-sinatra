require 'helper'

Signal.trap('INT') { exit 1 } # so Ctrl-C stops sleep

describe 'sleep', type: :feature, js: true do
  it 'sleeps' do
    visit 'http://127.0.0.1:3000' # necessary to start web server
    sleep
  end
end
