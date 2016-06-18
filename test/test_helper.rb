require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'chainable_methods'

require 'minitest/spec'
require 'minitest/autorun'

require 'pry'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb

  config.ignore_hosts 'codeclimate.com'
end
