# This file is part of KalibroClient
# Copyright (C) 2013  it's respectives authors (please see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'spec_helper'
require 'likeno/helpers/aggregation_options'

include Likeno::AggregationOptions

describe Likeno::AggregationOptions do
  describe 'all_with_label' do
    it 'should return the list of aggregation methods available' do
      expect(all_with_label).to eq(
        [
          ["Mean","mean"], ["Median", "MEDIAN"], ["Maximum", "max"], ["Minimum", "min"],
          ["Count", "COUNT"], ["Standard Deviation", "STANDARD_DEVIATION"]
        ]
      )
    end
  end
end
