# This file is part of Likeno. Copyright (C) 2013-2016 The Mezuro Team

# Likeno is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Likeno is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with Likeno.  If not, see <http://www.gnu.org/licenses/>.

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
