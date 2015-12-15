$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'likeno'

RSpec.configure do |config|
  config.mock_with :mocha
end
