#!/usr/bin/ruby
require 'net/http'
require 'uri'
require 'openssl'
require 'pp'
require 'json'

URL = ARGV[0] or raise "For arg 1, provide URL to test"

# ------------ Part 1: start the tests

LINUX_CHROME = ["Linux", "googlechrome", ""]
WINXP_IE8    = ["Windows XP", "Internet Explorer", "8"]
MAC_CHROME   = ["OS X 10.9", "chrome", ""]

sha = ENV['GIT_COMMIT'] ? ENV['GIT_COMMIT'][0...7] : 'ad-hoc'
post_data = {
  platforms: [LINUX_CHROME],
  url:       URL,
  framework: "jasmine",
  name:      "Jasmine tests for #{sha}",
  build:     ENV['BUILD_NUMBER'], # will be set if run from Jenkins
}

url = "https://saucelabs.com/rest/v1/#{ENV['SAUCE_USERNAME']}/js-tests"
puts "Requesting #{url}..."
uri = URI.parse(url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
request = Net::HTTP::Post.new(uri.request_uri)
request.basic_auth ENV['SAUCE_USERNAME'], ENV['SAUCE_ACCESS_KEY']
request.body = post_data.to_json
request['Content-Type'] = 'application/json'
response = http.request(request)
raise "Non-200 status of #{response.inspect}" if response.code.to_i != 200
SAUCE_SESSION = response.body

# --------------------- Part 2: monitor test progress

test_ids = JSON.parse(SAUCE_SESSION)['js tests']
num_seconds_to_sleep = 1

while true

  url = "https://saucelabs.com/rest/v1/#{ENV['SAUCE_USERNAME']}/js-tests/status"
  puts "Requesting #{url}..."
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  request = Net::HTTP::Post.new(uri.request_uri)
  request.basic_auth ENV['SAUCE_USERNAME'], ENV['SAUCE_ACCESS_KEY']
  request.body = SAUCE_SESSION
  request['Content-Type'] = 'application/json'
  response = http.request(request)
  raise "Non-200 status of #{response.inspect}" if response.code.to_i != 200
  
  tests = JSON.parse(response.body)['js tests']
  results = {}
  test_id_to_passed = {}
  tests.each do |test|
    id = test['id']
    if test['result']
      if test['result']['message']
        puts test['result']['message']
      end
      passed = test['result']['passed'] || false
      test_id_to_passed[id] = passed
    end
  end
  puts "#{test_id_to_passed.size} finished so far"

  if test_id_to_passed.size == test_ids.size
    num_failed = 0
    test_id_to_passed.each do |test_id, passed|
      num_failed += 1 if passed == false
    end
    if num_failed == 0
      puts "All #{test_ids.size} tests passed"
      exit 0
    else
      puts "#{num_failed} tests failed out of #{test_ids.size}"
      exit 1
    end
  else
    puts "Sleeping #{num_seconds_to_sleep} seconds..."
    sleep num_seconds_to_sleep
    num_seconds_to_sleep += 1 # slow down if tests are taking a while
    # now go loop again
  end
end
