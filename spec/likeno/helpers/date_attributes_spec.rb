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

require 'spec_helper'
require 'likeno/helpers/date_attributes'

include Likeno::DateAttributes

class Klass
  include Likeno::DateAttributes
end


describe Likeno::DateAttributes do
  subject { Klass.new }
  let(:time){ "2015-02-04T15:53:18.452Z" }

  describe 'created_at=' do
    it 'is expected to parse it to DateTime' do
      DateTime.expects(:parse).with(time)

      subject.created_at = time
    end
  end

  describe 'updated_at=' do
    it 'is expected to parse it to DateTime' do
      DateTime.expects(:parse).with(time)

      subject.updated_at = time
    end
  end
end
