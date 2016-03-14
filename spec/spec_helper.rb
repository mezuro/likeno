$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'factory_girl'
require 'simplecov'

SimpleCov.start do
  add_group 'Likeno', 'lib/likeno'
  add_group 'Errors', 'lib/errors'
  add_group 'Helpers', 'lib/helpers'

  add_filter '/spec/'
end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'likeno'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.mock_with :mocha
  config.include FactoryGirl::Syntax::Methods
end
