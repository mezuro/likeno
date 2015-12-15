$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'likeno'
require 'factory_girl'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.mock_with :mocha
  config.include FactoryGirl::Syntax::Methods
end
